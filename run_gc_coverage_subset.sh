#!/bin/bash
#SBATCH --job-name=gc_cov_sub
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=04:00:00
#SBATCH --constraint=avx512
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/%j.gc_cov_sub.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/%j.gc_cov_sub.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

source ~/assembly/scripts/sparvus_config.sh

module load uri/main
module load samtools/1.19.2
module load seqtk/1.4-GCC-12.3.0

source /modules/opt/linux-ubuntu24.04-x86_64/miniforge3/24.7.1/etc/profile.d/conda.sh
conda activate /work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/assembly_env

OUTDIR=${SCRATCH_DIR}/contamination_check/gc_coverage_subset
mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "Assembly: $ASSEMBLY"
echo "Reads: $HIFI_READS"
echo "Started: $(date)"

# Subsample 500,000 HiFi reads
seqtk sample -s100 "$HIFI_READS" 500000 > hifi_subset_500k.fastq

# GC/length table
seqkit fx2tab -n -l -g "$ASSEMBLY" > contig_gc_length.tsv

# Map subset back to assembly
minimap2 -ax map-hifi -t 16 "$ASSEMBLY" hifi_subset_500k.fastq | \
  samtools sort -@ 8 -o hifi_subset_vs_assembly.bam

samtools index hifi_subset_vs_assembly.bam

samtools coverage hifi_subset_vs_assembly.bam > hifi_subset_vs_assembly.coverage.tsv

echo "Finished: $(date)"
