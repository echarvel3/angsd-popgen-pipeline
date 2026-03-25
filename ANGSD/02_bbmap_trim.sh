#!/bin/bash
#SBATCH --job-name=bbmap_trim
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=14
#SBATCH --time=48:00:00
#SBATCH --output=%x.%J.out
#SBATCH --error=%x.%J.err

#!/bin/bash
# ===========================================================
# Adapter/quality trimming of WGS reads with bbduk.sh
# Requires skimming_scripts (https://github.com/smirarab/skimming_scripts)
# ===========================================================

BBDUK="${HOME}/programs/bbmap/bbduk.sh"
SUFFIX=$2
srr=$(ls -tr ./$1/SRR* | sed -e s/_.${SUFFIX}//g | sort -u | awk -v var=${SLURM_ARRAY_TASK_ID} 'NR==var')
# Loop through your SRR ids (or any IDs you reads are in)

echo "Trimming $srr ..."

$BBDUK \
    in1=${srr}_1${SUFFIX} \
    in2=${srr}_2${SUFFIX} \
    out1=./trimmed_reads/$(basename $srr)_1_trimmed${SUFFIX} \
    out2=./trimmed_reads/$(basename $srr)_2_trimmed${SUFFIX} \
    ref=adapters,phix \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe tbo \
    qtrim=rl \
    trimq=20

echo "Samples trimmed ready for next step!"

# filters:
# ref=adapters,phix → remove Illumina adapters + phiX control
# ktrim=r → trim adapters from the right end of reads
# k=23, mink=11 → use 23-mers, allow shorter 11-mers at read ends
# hdist=1 → allow 1 mismatch in kmer matches
# tpe tbo → trim both reads equally + trim based on pair overlap
# qtrim=rl → quality-trim both ends (right & left)
# trimq=20 → clip low-quality tails (bases < Q20)
