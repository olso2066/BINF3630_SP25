#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --job-name=blast
#SBATCH --output=blast_%a.out
#SBATCH --error=blast_%a.err
#SBATCH --mem=20G
#SBATCH --cpus-per-task=4

module load ncbi-blast/2.16.0

# Only do these next steps once
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip uniprot_sprot.fasta.gz

# Build a blasat data base
makeblastdb -in uniprot_sprot.fasta -dbtype prot

# do a blastx search 
blastx -query trinity_out_dir.Trinity.fasta -db uniprot_sprot.fasta -out blastx.outfmt6 -evalue 1e-20 -outfmt 0 

