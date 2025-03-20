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

# Set up directories
INPUT_DIR="/anvil/projects/x-bio250083/RNAseq_mdg"
OUTPUT_DIR="/anvil/projects/x-bio250083/olsonman_RNAseq"
mkdir -p "$OUTPUT_DIR"

# Define sample names
SAMPLE_R1="$INPUT_DIR/mdg_017_L_S17_L004_R1_001.fastq.gz"
SAMPLE_R2="$INPUT_DIR/mdg_017_L_S17_L004_R2_001.fastq.gz"

# Step 1: Subsample and trim with fastp
fastp -i "$SAMPLE_R1" -I "$SAMPLE_R2" \
      -o "$OUTPUT_DIR/out17.R1.fq.gz" -O "$OUTPUT_DIR/out17.R2.fq.gz" \
      --max_reads 10000 \
      --thread 2

# Step 2: Run FastQC on trimmed reads
fastqc "$OUTPUT_DIR/out17.R1.fq.gz" "$OUTPUT_DIR/out17.R2.fq.gz" \
        --outdir "$OUTPUT_DIR"


