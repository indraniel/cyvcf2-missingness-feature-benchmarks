CHROM := chr14

MASTER_VCF := data/ALL.$(CHROM).phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
MASTER_TBI := $(MASTER_VCF).tbi

CONTROL_VENV := vendor/venv/control
CONTROL_CYVCF2 := $(CONTROL_VENV)/lib/python2.7/site-packages/cyvcf2/cyvcf2.pyx
CONTROL_BENCHMARK := data/control-benchmark.dat

ALT_VENV := vendor/venv/alternative
ALT_CYVCF2 := $(ALT_VENV)/lib/python2.7/site-packages/cyvcf2/cyvcf2.pyx
ALT_BENCHMARK := data/alternative-benchmark.dat

.PHONY: clean plot record

all: $(CONTROL_BENCHMARK) $(ALT_BENCHMARK)

gen-test-file-name = data/$(CHROM).p3.$(1).subset.unphased.random.missing.vcf.gz.tbi

variants := 1000 5000 10000 15000 20000 50000 100000 500000 1000000
test-files := $(foreach a, $(variants), $(call gen-test-file-name,$(a)))

$(CONTROL_BENCHMARK) $(ALT_BENCHMARK): | $(test-files) $(CONTROL_CYVCF2) $(ALT_CYVCF2)
	@echo "Control (original) code"
	source $(CONTROL_VENV)/bin/activate && \
		python bin/benchmark-cyvcf2.py $(CHROM) > $(CONTROL_BENCHMARK)
	@echo "Alternative (missingness) code"
	source $(ALT_VENV)/bin/activate && \
		python bin/benchmark-cyvcf2.py $(CHROM) > $(ALT_BENCHMARK)

$(test-files): data/$(CHROM).p3.%.subset.unphased.random.missing.vcf.gz.tbi: | $(MASTER_TBI)
	$(eval rows := $(shell echo $@ | perl -F$$'\.' -lane 'print $$F[2]'))
	bin/make-data.sh $(CHROM) $(rows)

$(CONTROL_CYVCF2):
	mkdir -p vendor/venv
	virtualenv $(CONTROL_VENV)
	source $(CONTROL_VENV)/bin/activate && \
		pip install --no-cache-dir git+https://github.com/brentp/cyvcf2.git

$(ALT_CYVCF2):
	mkdir -p vendor/venv
	virtualenv $(ALT_VENV)
	source $(ALT_VENV)/bin/activate && \
		pip install --no-cache-dir git+https://github.com/indraniel/cyvcf2.git@option-missingness#egg=cyvcf2

$(MASTER_TBI):
	bin/make-data.sh $(CHROM)

clean:
	rm -rf $(CONTROL_VENV)
	rm -rf $(ALT_VENV)
	rm -rf data/$(CHROM).*
	rm -f $(CONTROL_BENCHMARK) $(ALT_BENCHMARK)
	rm -f data/*.png

plot:
	Rscript bin/plot-timings.r

record:
	mkdir -p results
	cp -rv data/*.png results
	cp -rv $(CONTROL_BENCHMARK) results
	cp -rv $(ALT_BENCHMARK) results
