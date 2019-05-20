#!/bin/bash
if [ "$SPECIES" == "" ]
then
    SPECIES="$1"
fi
if [ "$SPECIES" == "" ]
then
    echo USAGE: $0 SPECIES
fi

module load gnuplot java/jdk1.8.0_60 canu/1.7.1

set -euo pipefail # safe mode
set -x # logging

GRID_OPTIONS="-P xe2 -q express -l software=canu -l wd -m ae -M pbs@kdmurray.id.au -l walltime=25:00:00"

HERE=/g/data/xe2/projects/euc_pan_genome/
DIR=$HERE/workspaces/$SPECIES/canu
mkdir -p $DIR
cd $DIR

canu                                                                      \
    -p $SPECIES                                                           \
    -d $DIR                                                               \
    -nanopore-raw $HERE/workspaces/$SPECIES/reads/${SPECIES}-qcd.fastq.gz \
    genomeSize=650m                                                       \
    correctedErrorRate=0.2                                                \
    maxThreads=1008                                                       \
    maxMemory=120                                                         \
    gridOptionsExecutive="-q express -l walltime=01:00:00"                \
    saveReads=true                                                        \
    gridOptions="$GRID_OPTIONS"                                           \
    gridEngineThreadsOption="-l ncpus=THREADS"                            \
    java=$(which java)                                                    \
    stageDirectory='$PBS_JOBFS'                                           \
    gridEngineStageOption="-l jobfs=400GB"                                \
    gnuplot=$(which gnuplot)                                              \
    useGrid=true                                                          \

# leave a blank line
