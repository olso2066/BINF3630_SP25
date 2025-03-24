!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --job-name=abundance
#SBATCH --output=abundance_%A_%a.out
#SBATCH --error=abundance_%A_%a.out
#SBATCH --mem=20G
#SBATCH --cpus-per-task=10

ml biocontainers trinity/2.15.0 samtools

mkdir -p $SCRATCH/RNAseq/salmon_out

align_and_estimate_abundance.pl --transcripts $SCRATCH/RNAseq/trinity_out_dir/Trinity.fasta \
--seqType fq \
--left $SCRATCH/RNAseq/clean.R1.fq.gz \
--right $SCRATCH/RNAseq/clean.R2.fq.gz \
--est_method salmon --output $SCRATCH/RNAseq/salmon_out --prep_reference
