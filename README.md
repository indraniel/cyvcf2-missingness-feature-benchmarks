_This repository contains the logic to reproduce the benchmarking metrics for cyvcf2's [missingness feature][0]._

# Testing Methodology

## Setup / Generate a test data set

I downloaded a 1000 Genomes VCF for chromosome 14 and performed the following modification on the downloaded file:

1.  subsetted the VCF to 100 samples 
2.  subsetted number of variants to certain variant set thresholds (5,000; 10,000; 15,000; 20,000; 100,000; 500,000; and 1,000,000).
3.  converted all genotypes from phased to unphased
4.  randomly added missing variants (e.g. `./0`, `0/.`, `1/.`, `./1`, `./.`) _(up to 10% percent of the genotypes on each variant line)_

Step 4 was done to ensure that we're going though all the new logic introduced by the new missingness feature.

See [bin/make-data.sh][6] and [bin/add-random-missingness.py][7] for the details.

## Benchmarking

I ran the following code 10 times for each variant set on the two different code bases (one with and without the new missingness feature), and noted the execution timings:

```python
def benchmark(vcf):
    vcf = cyvcf2.VCF(vcf)
    
    for variant in vcf:
        variant.gt_types
```

See [bin/benchmark-cyvcf2.py][1] for the details.

## Results

Looks like the new feature makes the code slightly slower for a small number of variants, but has comparatively similar timings when the number of variants gets into the millions.

### Raw Data

* [Raw data timings with the original code base (without the missingness feature)][2]
* [Raw data times with the new code base (with the missingness feature)][3]

### Plots

![Benchmarking Execution Times (Linear Scale)][4]
![Benchmarking Execution Times (Log Scale)][5]


[0]: https://github.com/brentp/cyvcf2/pull/55
[1]: https://github.com/indraniel/cyvcf2-missingness-feature-benchmarks/blob/master/bin/benchmark-cyvcf2.py
[2]: https://github.com/indraniel/cyvcf2-missingness-feature-benchmarks/blob/master/results/control-benchmark.dat
[3]: https://github.com/indraniel/cyvcf2-missingness-feature-benchmarks/blob/master/results/alternative-benchmark.dat
[4]: https://github.com/indraniel/cyvcf2-missingness-feature-benchmarks/blob/master/results/benchmark.png
[5]: https://github.com/indraniel/cyvcf2-missingness-feature-benchmarks/blob/master/results/benchmark-log-scale.png
[6]: https://github.com/indraniel/cyvcf2-missingness-feature-benchmarks/blob/master/bin/make-data.sh
[7]: https://github.com/indraniel/cyvcf2-missingness-feature-benchmarks/blob/master/bin/add-random-missingness.sh
