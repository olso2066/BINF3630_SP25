#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --job-name=blast
#SBATCH --output=blast_%a.out
#SBATCH --error=blast_%a.err
#SBATCH --mem=20G
#SBATCH --cpus-per-task=4

ml biocontainers blast/2.13.0

# Only do these next steps once - if the blast fails, make sure to 
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
mv uniprot_sprot.fasta.gz $SCRATCH/RNAseq/
gunzip $SCRATCH/RNAseq/uniprot_sprot.fasta.gz

# Build a blasat data base
makeblastdb -in $SCRATCH/RNAseq/uniprot_sprot.fasta -dbtype prot

# do a blastx search
blastx -query $SCRATCH/RNAseq/trinity_out_dir.Trinity.fasta -db $SCRATCH/RNAseq/uniprot_sprot.fasta -out $SCRATCH/RNAseq/blastx.outfmt6 -evalue 1e-20 -outfmt 0 
