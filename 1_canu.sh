#!/bin/bash
if [ "$SPECIES" == "" ]
then
    SPECIES="$1"
fi
if [ "$SPECIES" == "" ]
then
    echo USAGE: $0 SPECIES
fi

module load gnuplot java/jdk1.8.0_60 canu

set -euo pipefail # safe mode
set -x # logging

GRID_OPTIONS="-P xe2 -q expressbw -l jobfs=400GB -l software=canu -l wd -N ${SPECIES}_canu -m abe -M pbs@kdmurray.id.au -l walltime=4:00:00"

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
    maxMemory=250                                                         \
    merylThreads=28                                                       \
    merylMemory=63                                                        \
    corThreads=28                                                         \
    corMemory=63                                                          \
    gridOptions="$GRID_OPTIONS"                                           \
    gridEngineThreadsOption="-l ncpus=THREADS"                            \
    executiveMemory=2                                                     \
    executiveThreads=1                                                    \
    java=$(which java)                                                    \
    gnuplot=$(which gnuplot)                                              \
    useGrid=false                                                          \
    #useGrid=true                                                          \

# leave a blank line
