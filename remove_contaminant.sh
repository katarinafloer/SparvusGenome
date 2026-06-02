#!/bin/bash

# do not run this. just keeping record of how I removed the nematode contig

conda activate /work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/assembly_env

cd /scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/assembly_output

seqkit grep -v -p ptg003819l \
    sparvus_primary_contigs.fa \
    > sparvus_primary_contigs.ncbi.fa

grep -c "^>" sparvus_primary_contigs.fa
grep -c "^>" sparvus_primary_contigs.ncbi.fa

grep "ptg003819l" sparvus_primary_contigs.ncbi.fa

grep -v "^>" sparvus_primary_contigs.ncbi.fa | tr -d '\n' | wc -c


