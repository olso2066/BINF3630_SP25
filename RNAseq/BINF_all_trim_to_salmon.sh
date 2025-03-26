#!/bin/bash
#SBATCH --time=06:00:00
#SBATCH --job-name=RNAseq-pipeline
#SBATCH --output=pipeline_%j.out
#SBATCH --error=pipeline_%j.err
#SBATCH --mem=150G
#SBATCH --cpus-per-task=20


# Load required modules
ml biocontainers fastp/0.23.2 fastqc/0.12.1 bbmap
ml biocontainers trinity/2.15.0 samtools bowtie2 blast/2.13.0
ml seqkit/2.3.1

# Directories
INPUT_DIR="/anvil/projects/x-bio250083/RNAseq_mdg"
SCRATCH_DIR="$SCRATCH/RNAseq"
mkdir -p "$SCRATCH_DIR/blastx_output" "$SCRATCH_DIR/salmon_out" "$SCRATCH_DIR/trinity_output"

# Reference DB setup
DB_FASTA="$SCRATCH_DIR/smr_v4.3_fast_db.fasta"
DB_URL="https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz"
DB_ARCHIVE="$SCRATCH_DIR/database.tar.gz"
if [ ! -f "$DB_FASTA" ]; then
    echo "Downloading rRNA reference database..."
    wget -O "$DB_ARCHIVE" "$DB_URL"
    tar -xzf "$DB_ARCHIVE" -C "$SCRATCH_DIR"
fi

# ====== STEP 1: Process All Samples ======
echo "Detecting samples..."
cd "$INPUT_DIR"
# all leaf samples
for R1 in *_L_*_R1_001.fastq.gz; do
    SAMPLE_BASE=$(basename "$R1" _R1_001.fastq.gz)
    R2="${SAMPLE_BASE}_R2_001.fastq.gz"
    echo "Processing sample: $SAMPLE_BASE"
    OUT_DIR="$SCRATCH_DIR/$SAMPLE_BASE"
    mkdir -p "$OUT_DIR"
    cd "$OUT_DIR" || exit 1
  # fastp: Trim & Subsample
    if [ ! -f out.R1.fq.gz ]; then
        fastp -i "$INPUT_DIR/$R1" -I "$INPUT_DIR/$R2" \
              -o out.R1.fq.gz -O out.R2.fq.gz \
              --reads_to_process 50000 --thread 4 \
              --html fastp.html --json fastp.json
    fi
    # bbsplit: Remove rRNA
    if [ ! -f clean.R1.fq.gz ]; then
        bbsplit.sh in1=out.R1.fq.gz in2=out.R2.fq.gz \
                   ref="$DB_FASTA" \
                   outu1=clean.R1.fq.gz outu2=clean.R2.fq.gz \
                   outm1=rRNA.R1.fq.gz outm2=rRNA.R2.fq.gz \
                   threads=4
    fi
    # FastQC (optional)
    fastqc clean.R1.fq.gz clean.R2.fq.gz --outdir "$OUT_DIR"
 done

# ====== STEP 2: Combined Trinity Assembly ======
echo "Running Trinity assembly on combined cleaned reads..."
cat $(find "$SCRATCH_DIR" -name clean.R1.fq.gz) > "$SCRATCH_DIR/all_clean.R1.fq.gz"
cat $(find "$SCRATCH_DIR" -name clean.R2.fq.gz) > "$SCRATCH_DIR/all_clean.R2.fq.gz"

# ====== STEP 2: Combined Trinity Assembly ======
echo "Running Trinity assembly on combined cleaned reads..."
cat $(find "$SCRATCH_DIR" -name clean.R1.fq.gz) > "$SCRATCH_DIR/all_clean.R1.fq.gz"
cat $(find "$SCRATCH_DIR" -name clean.R2.fq.gz) > "$SCRATCH_DIR/all_clean.R2.fq.gz"

Trinity --seqType fq \
        --left "$SCRATCH_DIR/all_clean.R1.fq.gz" \
        --right "$SCRATCH_DIR/all_clean.R2.fq.gz" \
        --CPU 20 --max_memory 150G \
        --full_cleanup \
        --output "$SCRATCH_DIR/trinity_output"

# ====== STEP 3: Align Reads Back to Assembly ======
cd "$SCRATCH_DIR" || exit 1
ASSEMBLY="$SCRATCH_DIR/trinity_output/Trinity.fasta"
INDEX_PREFIX="trinity_index"
echo "Building Bowtie2 index..."
bowtie2-build "$ASSEMBLY" "$INDEX_PREFIX"
echo "Aligning reads back to assembly..."
bowtie2 -p 16 -q --no-unal -k 20 -x "$INDEX_PREFIX" \
    -1 "$SCRATCH_DIR/all_clean.R1.fq.gz" \
    -2 "$SCRATCH_DIR/all_clean.R2.fq.gz" \

samtools view -@10 -Sb -o bowtie2.bam

# ====== STEP 4: BLASTX Search ======
BLAST_DB="$SCRATCH_DIR/uniprot_sprot.fasta"
if [ ! -f "$BLAST_DB" ]; then
    echo "Downloading UniProt database..."
    wget -O "$SCRATCH_DIR/uniprot_sprot.fasta.gz" \
         ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
    gunzip "$SCRATCH_DIR/uniprot_sprot.fasta.gz"
    makeblastdb -in "$BLAST_DB" -dbtype prot
fi
echo "Running BLASTX..."
blastx -query "$ASSEMBLY" -db "$BLAST_DB" \
       -out "$SCRATCH_DIR/blastx_output/blastx.outfmt6" \
       -evalue 1e-20 -outfmt 6 -num_threads 10

# ====== STEP 5: Estimate Abundance per Sample with Salmon ======
for SAMPLE_DIR in "$SCRATCH_DIR"/mdg*/; do
    SAMPLE=$(basename "$SAMPLE_DIR")
    echo "Estimating abundance for sample: $SAMPLE"
    align_and_estimate_abundance.pl \
        --transcripts "$ASSEMBLY" \
        --seqType fq \
        --left "$SAMPLE_DIR/clean.R1.fq.gz" \
        --right "$SAMPLE_DIR/clean.R2.fq.gz" \
        --est_method salmon \
        --output "$SCRATCH_DIR/salmon_out/$SAMPLE" \
        --prep_reference
done
echo "Pipeline complete."
