#!/bin/bash
if [ "$SPECIES" == "" ]
then
    SPECIES="$1"
fi
if [ "$SPECIES" == "" ]
then
    echo USAGE: $0 SPECIES
fi

module load gnuplot java/jdk1.8.0_60

set -euo pipefail # safe mode
set -x # logging

GRID_OPTIONS="-P xe2 -q normalbw -l jobfs=400GB -l software=canu -l wd -N ${SPECIES}_canu -m abe -M pbs@kdmurray.id.au -l walltime=48:00:00"

HERE=/g/data/xe2/projects/euc_pan_genome/
DIR=$HERE/workspaces/$SPECIES/canu-experimental
mkdir -p $DIR
cd $DIR

/g/data/xe2/opt/tmp/canu/Linux-amd64/bin/canu                                  \
    -p $SPECIES                                                                \
    -d $DIR                                                                    \
    -correct                                                                   \
    -nanopore-raw $HERE/workspaces/$SPECIES/reads/${SPECIES}-qcd_main.fastq.gz \
    useGrid=remote                                                             \
    genomeSize=650m                                                            \
    correctedErrorRate=0.2                                                     \
    maxThreads=28                                                              \
    gridOptions="$GRID_OPTIONS"                                                \
    gridEngineResourceOption="-l ncpus=THREADS,mem=MEMORY"                     \
    gridOptionsExecutive="-l walltime=00:30:00 -q expressbw -l mem=3G"         \
    stageDirectory='$PBS_JOBFS'                                                \
    executiveMemory=2                                                          \
    executiveThreads=1                                                         \
    java=$(which java)                                                         \
    gnuplot=$(which gnuplot)                                                   \
    corMhapThreads="14"                                                        \
    corMhapMemory="60"                                                         \
    gridOptionscormhap="-q expressbw -l walltime=12:00:00"                     \
    corThreads=14                                                              \
    corMemory=63                                                               \
    gridOptionscor="-q expressbw -l walltime=12:00:00"                         \



#    corOvlThreads="2"           \
#    obtOvlThreads="7"           \
#    utgOvlThreads="7"           \
#    obtMhapThreads="14"         \
#    obtMhapMemory="100"         \
#    utgMhapThreads="14"         \
#    utgMhapMemory="100"         \
#    corMMapThreads="14"         \
#    obtMMapThreads="14"         \
#    utgMMapThreads="14"         \
#    corThreads="4"              \
#    cnsThreads="4-7"            \
#    merylThreads="14"           \
#    merylMemory="63"            \
#    hapThreads="14-28"          \
#    oeaThreads="4-7"            \
#    redThreads="4-7"            \
#    batThreads="7-28"           \
#    dbgThreads="7-28"           \
#    gfaThreads="7-28"           \
#    batMemory="999"             \
#    gridOptionsbat="-q hugemem" \
#    merylThreads=28             \
#    merylMemory=63              \

# leave a blank line
