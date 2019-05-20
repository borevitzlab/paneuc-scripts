#!/usr/bin/env python3
import argparse
import sys

import screed


def n50(lengths):
    lengths.sort()
    total = sum(lengths)
    cumsum = 0
    for seqlen  in lengths:
        cumsum += seqlen
        if cumsum >= (total/2):
            return seqlen
    return 0


def process_fasta(fastafile):
    lengths = []
    with screed.open(fastafile) as sequences:
        for sequence in sequences:
            lengths.append(len(sequence.sequence))
    return lengths


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-o", "--outfile", type=argparse.FileType('w'), default=sys.stdout,
                    help="Output TSV file")
    ap.add_argument("assemblies", nargs='+', type=str,
                    help="Input genome assemblies")
    args = ap.parse_args()

    print("AssemblyFasta", "NumContigs", "TotalLength", "N50", sep="\t", file=args.outfile)
    for asm in args.assemblies:
        lengths = process_fasta(asm)
        print(asm, len(lengths), sum(lengths), n50(lengths), sep='\t', file=args.outfile)

if __name__ == "__main__":
    main()
