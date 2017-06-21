#!/usr/bin/env python

from __future__ import print_function

import timeit
import glob
import os
import sys

import cyvcf2
import numpy as np

def benchmark(vcf):
    vcf = cyvcf2.VCF(vcf)
    
    for variant in vcf:
        variant.gt_types

if __name__ == "__main__":
    # figure out the test files
    chrom = sys.argv[1]
    vcfs = glob.glob("data/{}.p3.*.subset.unphased.random.missing.vcf.gz".format(chrom))
    num_variants = [ int((v.split('.'))[2]) for v in vcfs ]
    num_variants.sort()

    # total number of test attempts to try
    repeats = 5
    
    # print a header
    trials = [ 'Trial{}'.format(x) for x in range(1, repeats+1) ]
    print("\t".join([x for sublist in (['# Variants'], trials) for x in sublist]))

    for rows in num_variants:
        vcf = os.path.join('data', '{}.p3.{}.subset.unphased.random.missing.vcf.gz'.format(chrom, rows))
#        print("--- vcf: {} ---".format(vcf))
        setup = "from __main__ import benchmark; import cyvcf2; import numpy as np; vcf = '{}'".format(vcf)
        times = timeit.repeat("benchmark(vcf)", setup=setup, repeat=repeats, number=1)
        print("\t".join([str(x) for sublist in ([rows], times) for x in sublist]))
