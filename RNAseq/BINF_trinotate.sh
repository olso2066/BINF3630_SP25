#!/bin/bash
#SBATCH -t 06:00:00
#SBATCH -N 1
#SBATCH -n 24
#SBATCH --job-name=trinotate
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --error=%x-%J-%u.err
#SBATCH --output=%x-%J-%u.out

ml biocontainers trinotate/3.2.2
# Check where the .pep file ends up

Build_Trinotate_Boilerplate_SQLite_db.pl Trinotate.sqlite

Trinotate /anvil/scratch/x-olsonman/RNAseq/Trinotate.sqlite init \
  --gene_trans_map /anvil/scratch/x-olsonman/RNAseq/trinity_output/Trinity.fasta.gene_trans_map \
  --transcript_fasta /anvil/scratch/x-olsonman/RNAseq/trinity_output/Trinity.fasta \
  --transdecoder_pep /anvil/scratch/x-olsonman/RNAseq/Trinity.fasta.transdecoder.pep

Trinotate Trinotate.sqlite LOAD_swissprot_blastx /anvil/scratch/x-olsonman/RNAseq/blastx.outfmt6
Trinotate Trinotate.sqlite LOAD_swissprot_blastp /anvil/scratch/x-olsonman/RNAseq/blastp.outfmt6
Trinotate Trinotate.sqlite LOAD_pfam /anvil/scratch/x-olsonman/RNAseq/pfam.domtblout
Trinotate Trinotate.sqlite report > trinotate_annotation_report.tsv
