#!/bin/bash
if [ "$SPECIES" == "" ]
then
    SPECIES="$1"
fi
if [ "$SPECIES" == "" ]
then
    echo USAGE: $0 SPECIES
fi

module load pigz nanopack zlib

set -euo pipefail # safe mode
set -x # logging

cd /g/data/xe2/projects/euc_pan_genome/
mkdir -p workspaces/${SPECIES}/reads
mkdir -p workspaces/${SPECIES}/log

find /g/data/xe2/datasets/minion-sequencing/flowcells/$SPECIES -name \*.fastq.gz | \
    xargs cat |                                                                    \
    tee workspaces/${SPECIES}/reads/${SPECIES}-raw.fastq.gz |                      \
    gzip -d |                                                                      \
    NanoLyse -r workspaces/DNA_CS.fasta                                            \
        2> workspaces/$SPECIES/log/${SPECIES}_nanolyse.log |                       \
    NanoFilt --headcrop 200 --tailcrop 200 --length 500 --quality 7                \
        2> workspaces/$SPECIES/log/${SPECIES}_nanofilt.log |                       \
    gzip > workspaces/${SPECIES}/reads/${SPECIES}-qcd.fastq.gz                     \

bash scripts/0_asmverify_split.sh "${SPECIES}"
