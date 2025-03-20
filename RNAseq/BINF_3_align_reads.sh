#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --job-name=align
#SBATCH --output=align_%a.out
#SBATCH --error=align_%a.err
#SBATCH --mem=20G
#SBATCH --cpus-per-task=4

# Load required modules
ml biocontainers trinity/2.15.0 samtools
ml bowtie2

# Align reads back to assembly 
bowtie2-build  trinity_out_dir.Trinity.fasta trinity_out_dir.Trinity.fasta
bowtie2 -p 10 -q --no-unal -k 20 -x trinity_index -1 out17.R1.fq.gz -2 out17.R2.fq.gz 2>align_stats.txt | \

# samtools view -@10 -Sb -o bowtie2.bam
