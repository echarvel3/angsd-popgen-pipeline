#!/bin/bash
#SBATCiH --job-name="index_genome"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=14
#SBATCH --time=48:00:00
#SBATCH --output=%x.%J.out
#SBATCH --error=%x.%J.err

# ===========================================================
# ANGSD pipeline: Map trimmed reads to reference (finches)
# ===========================================================
# Population: Certhidea fusca (Espanola, n=10)
# Reference: cfE7
#
# Steps:
#   1. Index reference genome
#   2. Map paired-end trimmed reads with BWA mem
#   3. Convert SAM → BAM
#   4. Sort BAMs
#   5. Create bamlist.txt with absolute paths
# ===========================================================

# Paths
REF=$1
BWA_PATH="${HOME}/programs/bwa/"
SAMTOOLS_PATH="${HOME}/programs/samtools-1.21/"

# -----------------------------------------------------------
# Step 1: Index the reference genome
# -----------------------------------------------------------
echo "Indexing reference genome..."
"${BWA_PATH}/"bwa index $REF
"${SAMTOOLS_PATH}"samtools faidx $REF

