#!/bin/bash
#SBATCH --time=0:10:00
#SBATCH --job-name=pre-process 
#SBATCH --output=pre-process_%A_%a.out
#SBATCH --error=pre-process_%A_%a.err
#SBATCH --mem=20G

# Basic pipeline from https://nf-co.re/denovotranscript/1.2.0/
# nf-core.re/denovotranscript/1.2.0/

# pre-processing
# assembly
# redundancy reduction
# quality assessment
# quantification
# reporting

## This script is for pre-processing ##
# fastqc - read qc of raw reads
# fastp - adapter and quality trimming (here, subsets fo 10,000 reads for illustration)
# SortMeRNA - remove rRNA and mitochondrial DNA

# import modules
ml biocontainers fastp/0.23.2 fastqc/0.12.1
ml sortmerna

# Set up directories
INPUT_DIR="/anvil/projects/x-bio250083/RNAseq_mdg"

### ENTER YOUR SAMPLE NAME 
SAMPLE_R1="$INPUT_DIR/mdg_017_L_S17_L004_R1_001.fastq.gz"
SAMPLE_R2="$INPUT_DIR/mdg_017_L_S17_L004_R2_001.fastq.gz"

OUTPUT_DIR="$SCRATCH/RNAseq"
mkdir -p "$OUTPUT_DIR"

cd "$OUTPUT_DIR"
cp "$SAMPLE_R1" "$OUTPUT_DIR"
cp "$SAMPLE_R2" "$OUTPUT_DIR"

# Define sample names
# change to your sample names ####
# SAMPLE_R1="$INPUT_DIR/mdg_017_L_S17_L004_R1_001.fastq.gz"
# SAMPLE_R2="$INPUT_DIR/mdg_017_L_S17_L004_R2_001.fastq.gz"

# Step 1: Subsample and trim with fastp
fastp -i "$SAMPLE_R1" -I "$SAMPLE_R2" \
      -o "$OUTPUT_DIR/out.R1.fq.gz" -O "$OUTPUT_DIR/out.R2.fq.gz" \
      --reads_to_process 10000 \ # we will only process a sub-sample for this RNAseq demonstration
      --thread 2


# Step 3: Remove rRNA and mitochondrial reads with SortMeRNA
SORTMERNA_OUT="$OUTPUT_DIR/sortmerna_out"
mkdir -p "$SORTMERNA_OUT"
sortmerna --ref smr_v4.3_fast_db.fasta \
    --reads "$OUTPUT_DIR/out17.R1.fq.gz","$OUTPUT_DIR/out17.R2.fq.gz" \
    --paired_in \
    --workdir "$SORTMERNA_OUT" \
    --fastx \
    --other "$SORTMERNA_OUT/non_rrna" \
    --aligned "$SORTMERNA_OUT/aligned"

# Step 2: Run FastQC on trimmed reads
fastqc "$OUTPUT_DIR/out.R1.fq.gz" "$OUTPUT_DIR/out.R2.fq.gz" \
        --outdir "$OUTPUT_DIR"


