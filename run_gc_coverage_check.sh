#!/bin/bash
#SBATCH --job-name=gc_cov
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/%j.gc_cov.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/%j.gc_cov.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

source ~/assembly/scripts/sparvus_config.sh

module load minimap2
module load samtools
module load seqkit

OUTDIR=${SCRATCH_DIR}/contamination_check/gc_coverage
mkdir -p "$OUTDIR"

cd "$OUTDIR"

echo "Assembly: $ASSEMBLY"
echo "Reads: $HIFI_READS"

seqkit fx2tab -n -l -g "$ASSEMBLY" > contig_gc_length.tsv

minimap2 -ax map-hifi -t 16 "$ASSEMBLY" "$HIFI_READS" | \
  samtools sort -@ 8 -o hifi_vs_assembly.bam

samtools index hifi_vs_assembly.bam

samtools coverage hifi_vs_assembly.bam > hifi_vs_assembly.coverage.tsv

echo "Done at $(date)"
