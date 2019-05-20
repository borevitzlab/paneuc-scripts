#!/usr/bin/env python3
#import screed
import argparse
import random
from sys import stdin, stdout, stderr, argv, exit
import gzip
import itertools
import os.path as op
import os

def fqitr(ifh):
    for h, s, _, q in zip(ifh, ifh, ifh, ifh):
        yield h, s, q

def printfq(h, s, q, file=None):
    file.write(h)
    file.write(s)
    file.write("+\n".encode('ascii'))
    file.write(q)

def main(input, outdir, proportion=0.9):
    if proportion > 1 or proportion < 0:
        print("Invalid proportion, must be 0 < proportion < 1", file=stderr)
        exit(1)
    mainprop = str(int(proportion * 100))
    smlprop = str(int((1-proportion) * 100))
    if outdir is None:
        outdir = op.dirname(input)
    if not op.isdir(outdir):
        os.makedirs(outdir)
    input_base = op.basename(input)
    for ext in [".gz", ".fastq", ".fasta"]:
        if input_base.endswith(ext):
            input_base = input_base[:-len(ext)]
    mainfh = open(op.join(outdir, input_base + ".main"), "wb")
    smlfh  = open(op.join(outdir, input_base + ".sml"), "wb")
    mainlen = 0
    smllen = 0

    with gzip.open(input, 'rb') as infh:
        progress = 0
        for seq in fqitr(infh):
            mp = mainlen / (mainlen + smllen + .001)  # + 1 to avoid div zero
            progress += len(seq[1]) - 1
            if mp < proportion:
                printfq(*seq, mainfh)
                mainlen += len(seq[1]) - 1
                dest = "main"
            else:
                printfq(*seq, smlfh)
                smllen += len(seq[1]) - 1
                dest = "sml"
            if progress > 1e7:
                print("main has", int(mainlen/1000), "k, small has", int(smllen/1000), "k, main proportion is", mp, file=stderr)
                progress = 0
    mp = mainlen / (mainlen + smllen + 1)  # + 1 to avoid div zero
    print("\nFinally, main has", mainlen, ", small has", smllen, ", main proportion is", mp, file=stderr)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("-p", "--proportion", type=float, default=0.9,
                    help="Proportion of sample in main file [0-1]")
    ap.add_argument("-o", "--outdir", type=str, default=None,
                    help="Output directory")
    ap.add_argument("input", type=str,
                    help="Input file")
    args = ap.parse_args()
    main(args.input,  args.outdir, args.proportion)
