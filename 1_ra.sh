#!/bin/bash
#PBS -P xe2
#PBS -q normalbw
#PBS -l walltime=48:00:00
#PBS -l mem=250G
#PBS -l jobfs=400GB
#PBS -l ncpus=28
#PBS -l wd
#PBS -m abe
#PBS -M pbs@kdmurray.id.au

if [ "$SPECIES" == "" ]
then
    SPECIES="$1"
fi
if [ "$SPECIES" == "" ]
then
    echo USAGE: $0 SPECIES
fi

module load ra

set -euo pipefail # safe mode
set -x            # logging

SELFSUB="${SELFSUB:-no}"
HERE=/g/data/xe2/projects/euc_pan_genome/
DIR=$HERE/workspaces/$SPECIES/ra
mkdir -p $DIR
cd $DIR
if [ "$SELFSUB" == "yes" ]
then
    NEXT=$(qsub -v SPECIES="$SPECIES",SELFSUB="$SELFSUB" -N "RA_$SPECIES" -W "depend=afterany:$PBS_JOBID"  $HERE/scripts/1_ra.sh)
fi

ra                                                               \
    -x ont                                                       \
    -t $PBS_NCPUS                                                \
    $HERE/workspaces/$SPECIES/reads/${SPECIES}-qcd_main.fastq.gz \
    > $DIR/${SPECIES}-assembly-ra.fa                             \
    2> $DIR/assembly.log


if [ "$SELFSUB" == "yes" ]
then
    qdel "$NEXT"
fi
