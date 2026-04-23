#!/bin/bash
#SBATCH --job-name="angsd_FST"
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
SAF_LIST=$(ls ${1}/*.saf.idx)
SFS_LIST=$(ls ${2}/*ml)
OUT=${3}

mkdir FST

# -----------------------------------------------------------
# Run realSFS
# -----------------------------------------------------------

#!/bin/bash
set -uo pipefail

REALSFS=/calab_data/mirarab/home/dairabel/angsd/realSFS
SAF_DIR=./SAF
SFS_DIR=./2D_SFS
FST_DIR=./FST
THREADS=4

mkdir -p "$FST_DIR"

POPS=(Dongying Qingdao Wenzhou)
echo $POPS

for i in "${!POPS[@]}"; do
    for j in "${!POPS[@]}"; do
        [[ $j -le $i ]] && continue

        POP1=${POPS[$i]}
        POP2=${POPS[$j]}

        SAF1=$SAF_DIR/${POP1}.bamlist.saf.idx
        SAF2=$SAF_DIR/${POP2}.bamlist.saf.idx

        # Try both orderings of the SFS filename
        if [[ -f "$SFS_DIR/${POP1}.bamlist.${POP2}.bamlist.ml" ]]; then
            SFS=$SFS_DIR/${POP1}.bamlist.${POP2}.bamlist.ml
        elif [[ -f "$SFS_DIR/${POP2}.bamlist.${POP1}.bamlist.ml" ]]; then
            SFS=$SFS_DIR/${POP2}.bamlist.${POP1}.bamlist.ml
        else
            echo "ERROR: no SFS found for ${POP1} x ${POP2}" >&2
            exit 1
        fi

        FSTOUT=$FST_DIR/${POP1}_${POP2}

        echo "=== Fst index: ${POP1} x ${POP2} ==="
        $REALSFS fst index "$SAF1" "$SAF2" -sfs "$SFS" -fstout "$FSTOUT"

        echo "=== Fst stats: ${POP1} x ${POP2} ==="
        echo -en "${POP1} x ${POP2}\t" >> "$FST_DIR/global_fst_summary.txt"
        $REALSFS fst stats "$FSTOUT.fst.idx" >> "$FST_DIR/global_fst_summary.txt"

        echo "=== Per-site Fst: ${POP1} x ${POP2} ==="
        #$REALSFS fst stats2 "$FSTOUT.fst.idx" -win 1 -step 1 > "$FSTOUT.persite.fst"

    done
done

echo ""
echo "Done. Global Fst summary:"
cat "$FST_DIR/global_fst_summary.txt" 

