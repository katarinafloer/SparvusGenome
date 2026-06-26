#!/bin/bash
#SBATCH --job-name=compress_GSE232203
#SBATCH --partition=cpu
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --time=08:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/compress_GSE232203_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/compress_GSE232203_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

PROJECT=/work/pi_lmangiamele_smith_edu/2023_adult_male_rnaseq_GSE232203

echo "Starting compression:"
date

find "$PROJECT/fastq" -type f -name '*.fastq' -print0 |
    xargs -0 -n 1 -P 8 gzip

echo "Compression finished:"
date

du -sh "$PROJECT"
find "$PROJECT/fastq" -type f | sort | xargs -r ls -lh
