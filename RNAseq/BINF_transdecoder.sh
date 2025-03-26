#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --job-name=transdecoder
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --error=%x-%J-%u.err
#SBATCH --output=%x-%J-%u.out
module --force purge
ml biocontainers transdecoder blast/2.13.0 hmmer/3.3.2
# /anvil/scratch/x-olsonman/RNAseq/trinity_output
TransDecoder.LongOrfs -t /anvil/scratch/x-olsonman/RNAseq/trinity_output/Trinity.fasta
blastp -query /anvil/scratch/x-olsonman/RNAseq/Trinity.fasta.transdecoder_dir/longest_orfs.pep \
       -db /anvil/scratch/x-olsonman/RNAseq/uniprot_sprot.fasta \
       -out /anvil/scratch/x-olsonman/RNAseq/blastp.outfmt6 \
       -evalue 1e-5 -num_threads 16 -outfmt 6
hmmpress Pfam-A.hmm
hmmscan --cpu 16 --domtblout pfam.domtblout \
        Pfam-A.hmm /anvil/scratch/x-olsonman/RNAseq/Trinity.fasta.transdecoder_dir/longest_orfs.pep
TransDecoder.Predict -t /anvil/scratch/x-olsonman/RNAseq/trinity_output/Trinity.fasta \
    --retain_pfam_hits pfam.domtblout \
    --retain_blastp_hits blastp.outfmt6
