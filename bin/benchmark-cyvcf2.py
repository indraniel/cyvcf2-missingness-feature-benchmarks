#!/usr/bin/env python

from __future__ import print_function

import timeit
import glob

import cyvcf2
import numpy as np

def benchmark(vcf):
    vcf = cyvcf2.VCF(vcf)
    
    for variant in vcf:
        variant.gt_types

if __name__ == "__main__":
    vcfs = glob.glob("chr14.p3.*.subset.unphased.random.missing.vcf.gz")
    for v in vcfs:
        print("--- vcf: {} ---".format(v))
        rows = (v.split('.'))[2]
        setup = "from __main__ import benchmark; import cyvcf2; import numpy as np; vcf = '{}'".format(v)
        datapoint = timeit.timeit("benchmark(vcf)", setup=setup, number=1)
        print("\t".join([str(rows), str(datapoint)]))
