#!/usr/bin/env python

from __future__ import print_function
import argparse, random, fileinput, sys

random.seed(1)

def add_missingness(num_missing):
    for line in fileinput.input(files=('-')):
        data = line.rstrip().split("\t")
        randomize = random.sample(range(9, len(data)), num_missing)
        for r in randomize:
            randint = random.randint(0,4)
            data[r] = ('./.', '0/.', './0', '1/.', './1')[randint]
        new_data = "\t".join(data)
        print(new_data)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--missingness",
                        type=int,
                        default=1,
                        help=("Number of random samples per variant "
                              "to change genotypes as 'missing' "
                              "[default=1]"))
    args = parser.parse_args()
    add_missingness(args.missingness)

if __name__ == "__main__":
    main()
