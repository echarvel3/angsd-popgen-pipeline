#!/bin/bash
#SBATCH --job-name="angsd_mapping"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --time=48:00:00
#SBATCH --mem=80gb
#SBATCH --output=angsd_mapping.%J.out
#SBATCH --error=angsd_mapping.%J.err

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

# Path
BWA_PATH=${HOME}/programs/bwa/
SAMTOOLS_PATH=${HOME}/programs/samtools-1.21/
READ_DIR=trimmed_reads
OUT_DIR=mapped_reads

mkdir -p $OUT_DIR

SUFFIX=$2
srr=$(ls ./${READ_DIR}/SRR* | xargs -I {} basename {} | sed -e s/_.${SUFFIX}//g | sort -u | awk -v var=${SLURM_ARRAY_TASK_ID} 'NR==var')
REF=$1


# -----------------------------------------------------------
# Step 2–4: Map reads, convert SAM → BAM, sort BAM
# -----------------------------------------------------------
    echo "Processing $srr..."

    fq1=${READ_DIR}/${srr}*_1${SUFFIX}
    fq2=${READ_DIR}/${srr}*_2${SUFFIX}

    SAM=${OUT_DIR}/${srr}_mapped.sam
    BAM=${OUT_DIR}/${srr}_mapped.bam
    SORTED_BAM=${OUT_DIR}/${srr}_mapped.sorted.bam

    # Map with BWA MEM
    ${BWA_PATH}/bwa mem -t 8 $REF $fq1 $fq2 > $SAM

    # Convert SAM → BAM
    ${SAMTOOLS_PATH}/samtools view -bS $SAM > $BAM
    rm $SAM
    # Sort BAM
    ${SAMTOOLS_PATH}/samtools sort -o $SORTED_BAM $BAM

    # Index sorted BAM
    ${SAMTOOLS_PATH}/samtools index $SORTED_BAM


echo "All done! BAMs ready for ANGSD."
