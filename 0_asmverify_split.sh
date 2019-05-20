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

(
set -xe
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

python3 scripts/split_fastq_asm_verify.py \
    -p 0.9                                \
    -o $TMP                               \
    "workspaces/${SPECIES}/reads/${SPECIES}-qcd.fastq.gz"



gzip -v "$TMP/${SPECIES}-qcd.main"
mv "$TMP/${SPECIES}-qcd.main.gz" "workspaces/${SPECIES}/reads/${SPECIES}-qcd_main.fastq.gz"

gzip -v "$TMP/${SPECIES}-qcd.sml"
mv "$TMP/${SPECIES}-qcd.sml.gz" "workspaces/${SPECIES}/reads/${SPECIES}-qcd_verify.fastq.gz"

) |& tee  workspaces/${SPECIES}/log/datasplit.log

