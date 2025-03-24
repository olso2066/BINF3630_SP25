
  GNU nano 2.9.8                                                                                      BINF_3_align_reads.sh                                                                                                
#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --job-name=align
#SBATCH --output=align_%A_%a.out
#SBATCH --error=align_%A_%a.err
#SBATCH --mem=20G
#SBATCH --cpus-per-task=10  # Matching -p 10 below
# Load required modules
ml biocontainers trinity/2.15.0 samtools
ml bowtie2
# Set working directory
cd $SCRATCH/RNAseq || { echo "Failed to cd to RNAseq directory"; exit 1; }
# Step 1: Build Bowtie2 index from Trinity assembly
ASSEMBLY="$SCRATCH/RNAseq/trinity_out_dir/Trinity.fasta"
INDEX_PREFIX="trinity_index"
if [ ! -f "${INDEX_PREFIX}.1.bt2" ]; then
    echo "Building Bowtie2 index..."
    bowtie2-build "$ASSEMBLY" "$INDEX_PREFIX"
else
    echo "Bowtie2 index exists. Skipping index build."
fi
# Step 2: Align cleaned reads back to assembly
echo "Aligning reads..."
bowtie2 -p 10 -q --no-unal -k 20 -x "$INDEX_PREFIX" \
    -1 clean.R1.fq.gz -2 clean.R2.fq.gz \
    2> align_stats.txt | \
samtools view -@10 -Sb -o bowtie2.bam
echo "Alignment complete. Output: bowtie2.bam"

