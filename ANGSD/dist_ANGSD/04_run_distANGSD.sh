#!/bin/bash
#SBATCH --job-name="distAngsd"
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
source ${HOME}/.bashrc

set -x

OUT_DIR=mapped_reads
ANGSD_DIR=distANGSD
distANGSD=${HOME}/programs/distANGSD/

mkdir -p $ANGSD_DIR
realpath $OUT_DIR/*.sorted.bam > $ANGSD_DIR/bams.txt
pushd $ANGSD_DIR

# Run all pairs
while read bam1; do
    while read bam2; do
        if [[ "$bam1" < "$bam2" ]]; then  # avoid duplicates
            s1=$(basename $bam1 .sorted.bam)
            s2=$(basename $bam2 .sorted.bam)
            
            # Make BCF for this pair
            bcftools mpileup -Ou -f ref.fa $bam1 $bam2 | \
            bcftools filter -Ou -e INFO/INDEL!=0 | \
            bgzip -c > ${s1}_${s2}.bcf.gz
            bcftools index ${s1}_${s2}.bcf.gz
            
            # Run distANGSD
            $distANGSD/distAngsd -vcf ${s1}_${s2}.bcf.gz -method geno -o ${s1}_${s2}_dist
        fi
    done < bams.txt
done < bams.txt

echo "All done! BAMs ready for ANGSD."
