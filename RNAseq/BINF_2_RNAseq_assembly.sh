#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --job-name=assembly
#SBATCH --output=assembly_%a.out
#SBATCH --error=assembly_%a.err
#SBATCH --mem=20G
#SBATCH --cpus-per-task=4
# Load required modules
ml biocontainers trinity/2.15.0 samtools
# /anvil/projects/x-bio250083/olsonman_RNAseq
Trinity --seqType fq \
--left /anvil/projects/x-bio250083/olsonman_RNAseq/out17.R1.fq.gz \
--right /anvil/projects/x-bio250083/olsonman_RNAseq/out17.R2.fq.gz \
--CPU 6 \
--max_memory 150G

