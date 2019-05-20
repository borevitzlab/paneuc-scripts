#!/bin/bash
#PBS -P xe2
#PBS -q expressbw
#PBS -l walltime=24:00:00
#PBS -l mem=200G
#PBS -l jobfs=400GB
#PBS -l ncpus=14
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

module load flye

set -euo pipefail # safe mode
set -x            # logging

SELFSUB="${SELFSUB:-no}"
HERE=/g/data/xe2/projects/euc_pan_genome/
DIR=$HERE/workspaces/$SPECIES/flye
mkdir -p $DIR
cd $DIR
if [ "$SELFSUB" == "yes" ]
then
    NEXT=$(qsub -v SPECIES="$SPECIES",SELFSUB="$SELFSUB" -N "FLYE_$SPECIES" -W "depend=afterany:$PBS_JOBID"  $HERE/scripts/1_flye.sh)
fi

if [ -f $DIR/params.json ]
then
    resume="--resume"
else
    resume=""
fi

flye                                                                        \
    --out-dir $DIR                                                          \
    --genome-size 700m                                                      \
    $resume                                                                 \
    --nano-raw $HERE/workspaces/$SPECIES/reads/${SPECIES}-qcd_main.fastq.gz \
    --threads $PBS_NCPUS                                                    \
    |& tee $HERE/workspaces/$SPECIES/log/flye.log


if [ -n "$NEXT" ]
then
    qdel "$NEXT"
fi
