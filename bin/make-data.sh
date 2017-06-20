#!/bin/bash

set -eo pipefail

export PATH=./bin:/Users/idas/idas/git/cyvcf2-benchmark/vendor/local/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH

function log {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "---> [ ${timestamp} ] $@" >&2
}

function download {
    local file=ALL.chr14.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
    local directory=vol1/ftp/release/20130502
    local server=ftp.1000genomes.ebi.ac.uk
    local url="ftp://${server}/${directory}/${file}"

    if [[ -e data/${file} ]]; then
        echo "${file}"
        return 0
    fi

    curl -O ${url} && mv -v ${file} data
    curl -O ${url}.tbi && mv -v ${file}.tbi data
    echo "${file}"
}

function subset {
    local invcf=${1}
    local rows=${2}
    local samples=${3}
    local outvcf="data/chr14.p3.${rows}.subset.vcf.gz"

    local endcol=$((${samples} + 9))

    cat <(bcftools view -h ${invcf} | head -n -1) \
        <(bcftools view -h ${invcf} | tail -n 1 | cut -f 1-${endcol}) \
        <(bcftools view -H ${invcf} | head -n ${rows} | cut -f 1-${endcol}) \
    | bgzip -c > ${outvcf}

    tabix -p vcf -f ${outvcf}

    echo ${outvcf}
}

function unphase {
    local invcf=${1}
    local outvcf=$(echo ${invcf} | perl -lape 's{.vcf.gz$}{.unphased.vcf.gz}')

    gunzip -c ${invcf} | perl -lape 's{(\d)\|(\d)}{\1\/\2}g' | bgzip -c > ${outvcf}
    tabix -p vcf -f ${outvcf}

    echo ${outvcf}
}

function add_random_missingness {
    local invcf=${1}
    local missing=${2}
    local outvcf=$(echo ${invcf} | perl -lape 's{.vcf.gz$}{.random.missing.vcf.gz}')

    cat <(bcftools view -h ${invcf}) \
        <(bcftools view -H ${invcf} | add-random-missingness.py -m ${missing}) \
    | bgzip -c > ${outvcf}

    tabix -p vcf -f ${outvcf}

    echo ${outvcf}
}

function main {
    local rows=$1
    local samples=100
    local missing=10

    local vcf=$(download)
    log "Subsetting (${vcf})"
    local subset_vcf=$(subset ${vcf} ${rows} ${samples})
    log "Unphasing (${subset_vcf})"
    local unphase_vcf=$(unphase ${subset_vcf})
    log "Add random missingness (${unphase_vcf})"
    local rnd_missing_vcf=$(add_random_missingness ${unphase_vcf} ${missing})
}

rows=$1

main ${rows};

# curl -u user:password 'ftp://mysite/%2fusers/myfolder/myfile/raw' -o ~/Downloads/myfile.raw
# https://stackoverflow.com/questions/1450393/how-do-you-read-from-stdin-in-python
# https://stackoverflow.com/questions/20816375/how-to-read-line-by-line-from-stdin-in-python
# https://stackoverflow.com/questions/7791559/how-to-read-a-file-or-stdin-line-by-line-in-python-not-waiting-for-reading-ent
