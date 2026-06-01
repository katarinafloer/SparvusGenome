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

module load uri/main
module load samtools/1.19.2

source /modules/opt/linux-ubuntu24.04-x86_64/miniforge3/24.7.1/etc/profile.d/conda.sh
conda activate /work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/assembly_env

which minimap2
which seqkit
which samtools

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
