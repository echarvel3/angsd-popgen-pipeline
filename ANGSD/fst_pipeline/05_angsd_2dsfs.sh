#!/bin/bash
#SBATCH --job-name="angsd_2dSDS"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=14
#SBATCH --time=120:00:00
#SBATCH --mem=120gb
#SBATCH --output=%x.%J.out
#SBATCH --error=%x.%J.err

# ===========================================================
# ANGSD Step 2: Estimate the Site Frequency Spectrum (SFS)
# ===========================================================
# Input: .saf.idx file from ANGSD Step 1
# Output: .sfs file containing the site frequency spectrum
# ===========================================================

set -x
POP1=$1
POP2=$2

mkdir 2D_SFS

# -----------------------------------------------------------
# Run realSFS
# -----------------------------------------------------------
/calab_data/mirarab/home/dairabel/angsd/realSFS $POP1 $POP2 > ./2D_SFS/$(basename ${POP1%.saf.idx}).$(basename ${POP2%.saf.idx}).ml

