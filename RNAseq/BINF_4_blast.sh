#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --job-name=blast
#SBATCH --output=blast_%a.out
#SBATCH --error=blast_%a.err
#SBATCH --mem=20G
#SBATCH --cpus-per-task=10

ml biocontainers blast/2.13.0 
ml seqkit/2.3.1

# Only do these next steps once - if the blast fails, make sure to hashtag this out
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
mv uniprot_sprot.fasta.gz $SCRATCH/RNAseq/
gunzip $SCRATCH/RNAseq/uniprot_sprot.fasta.gz

# Build a blasat data base
makeblastdb -in $SCRATCH/RNAseq/uniprot_sprot.fasta -dbtype prot

mkdir split_fasta
cd split_fasta
seqkit split -p 10 ../trinity_output/Trinity.fasta

# another way
# csplit -z -f chunk_ -n 2 ../trinity_output/Trinity.fasta '/^>/' '{*}'

mkdir ../blast_results
parallel -j 10 'blastx -query {} -db ../uniprot_sprot.fasta \
         -evalue 1e-20 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore slen" \
         -num_threads 1 -out ../blast_results/{/.}.blastx' ::: *.fasta

cat ../blast_results/*.blastx > blastx_combined.outfmt6


# do a blastx search
# blastx -query $SCRATCH/RNAseq/trinity_out_dir.Trinity.fasta -db $SCRATCH/RNAseq/uniprot_sprot.fasta -out $SCRATCH/RNAseq/blastx.outfmt6 -evalue 1e-20 -outfmt 0 
# blastx -query trinity_output/Trinity.fasta \
#        -db uniprot_sprot.fasta \
#        -out blastx.outfmt6 \
#        -evalue 1e-20 \
#        -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore slen" \
#        -num_threads 10
