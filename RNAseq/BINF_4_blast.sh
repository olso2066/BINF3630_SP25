#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --job-name=blast
#SBATCH --output=blast_A%_%a.out
#SBATCH --error=blast_A%_%a.err
#SBATCH --mem=20G
#SBATCH --cpus-per-task=10


ml biocontainers blast/2.13.0
ml seqkit/2.3.1

# Only do these next steps once - if the blast fails, make sure to hashtag this out
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
mv uniprot_sprot.fasta.gz $SCRATCH/RNAseq/
gunzip $SCRATCH/RNAseq/uniprot_sprot.fasta.gz
mkdir -p BLAST_db

# Build a blasat data base
makeblastdb -in $SCRATCH/RNAseq/BLAST_db/uniprot_sprot.fasta -dbtype prot

# do a blastx search
blastx -query trinity_out_dir/Trinity.fasta \
       -db /BLAST_db/uniprot_sprot.fasta \
       -out blastx.outfmt6 \
       -evalue 1e-20 \
       -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore slen" \
       -num_threads 10
