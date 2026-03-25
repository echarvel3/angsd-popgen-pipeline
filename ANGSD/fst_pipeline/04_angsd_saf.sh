#!/bin/bash
#SBATCH --job-name="angsd_matrix"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=14
#SBATCH --time=120:00:00
#SBATCH --mem=120gb
#SBATCH --output=angsd_sfs.%J.out
#SBATCH --error=angsd_sfs.%J.err

# ===========================================================
# ANGSD Step 2: Estimate the Site Frequency Spectrum (SFS)
# ===========================================================
# Input: .saf.idx file from ANGSD Step 1
# Output: .sfs file containing the site frequency spectrum
# ===========================================================

set -x

BAMLIST=$1
REF=$2
OUT=$3

mkdir SAF

# -----------------------------------------------------------
# Run realSFS
# -----------------------------------------------------------
/calab_data/mirarab/home/dairabel/angsd/angsd -b $BAMLIST -anc $REF -out ./SAF/${OUT} -doSaf 1 -GL 1 -doCounts 1 -doMajorMinor 1

echo "Done! SFS written to: ${BAMLIST%.bamlist}"
