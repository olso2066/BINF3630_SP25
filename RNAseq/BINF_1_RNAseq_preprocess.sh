#!/bin/bash
#SBATCH --time=0:10:00
#SBATCH --job-name=pre-process
#SBATCH --output=pre-process_%A_%a.out
#SBATCH --error=pre-process_%A_%a.err
#SBATCH --mem=20G
# Load required modules
ml biocontainers fastp/0.23.2 fastqc/0.12.1 bbmap
# ==== User Settings ====
INPUT_DIR="/anvil/projects/x-bio250083/RNAseq_mdg"
SAMPLE_NAME="mdg_017_L_S17_L004"  # <<< EDIT THIS FOR OTHER SAMPLES
SAMPLE_R1="$INPUT_DIR/${SAMPLE_NAME}_R1_001.fastq.gz"
SAMPLE_R2="$INPUT_DIR/${SAMPLE_NAME}_R2_001.fastq.gz"
SCRATCH_DIR="$SCRATCH/RNAseq"
OUTPUT_DIR="$SCRATCH_DIR/$SAMPLE_NAME"
DB_URL="https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz"
DB_ARCHIVE="$SCRATCH_DIR/database.tar.gz"
DB_FASTA="$SCRATCH_DIR/smr_v4.3_fast_db.fasta"
# ==== Create directories ====
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR" || { echo "Failed to change to $OUTPUT_DIR"; exit 1; }
# ==== Download and Extract Reference DB if Missing ====
if [ ! -f "$DB_FASTA" ]; then
    echo "Downloading rRNA reference database..."
    wget -O "$DB_ARCHIVE" "$DB_URL"
    echo "Extracting database..."
    tar -xzf "$DB_ARCHIVE" -C "$SCRATCH_DIR"
else
    echo "Reference database already exists: $DB_FASTA"
fi
# ==== Step 1: Trim and Subsample with fastp ====
FASTP_R1="out.R1.fq.gz"
FASTP_R2="out.R2.fq.gz"
if [ ! -f "$FASTP_R1" ] || [ ! -f "$FASTP_R2" ]; then
    echo "Running fastp trimming..."
    fastp -i "$SAMPLE_R1" -I "$SAMPLE_R2" \
          -o "$FASTP_R1" -O "$FASTP_R2" \
          --reads_to_process 100000 --thread 4 \
          --html fastp.html --json fastp.json
else
    echo "fastp output already exists, skipping trimming."
fi
# ==== Step 2: Remove rRNA Reads with BBsplit ====
CLEAN_R1="clean.R1.fq.gz"
CLEAN_R2="clean.R2.fq.gz"
if [ ! -f "$CLEAN_R1" ] || [ ! -f "$CLEAN_R2" ]; then
    echo "Running BBsplit to remove rRNA reads..."
    bbsplit.sh in1="$FASTP_R1" in2="$FASTP_R2" \
        ref="$DB_FASTA" \
        outu1="$CLEAN_R1" outu2="$CLEAN_R2" \
        outm1="rRNA.R1.fq.gz" outm2="rRNA.R2.fq.gz" \
        threads=4
else
    echo "Cleaned reads already exist, skipping BBsplit."
fi
# ==== Step 3: Run FastQC on Clean Reads (Optional) ====
# echo "Running FastQC..."
# fastqc "$CLEAN_R1" "$CLEAN_R2" --outdir "$OUTPUT_DIR"
echo "Pipeline completed for sample: $SAMPLE_NAME"
