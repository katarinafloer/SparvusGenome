#!/bin/bash
#SBATCH --job-name=download_GSE232203
#SBATCH --partition=cpu
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/download_GSE232203_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/download_GSE232203_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

PROJECT=/work/pi_lmangiamele_smith_edu/2023_adult_male_rnaseq_GSE232203
SRR_LIST=$PROJECT/runinfo/SRR_Acc_List.txt

mkdir -p "$PROJECT"/{sra,fastq,tmp,logs}
mkdir -p /home/kfloer_smith_edu/assembly/job_logs

module purge
module load sratoolkit/3.0.0

cd "$PROJECT"

echo "Using:"
which prefetch
which fasterq-dump
prefetch --version
fasterq-dump --version

echo "Starting prefetch:"
date

prefetch \
    --option-file "$SRR_LIST" \
    --output-directory "$PROJECT/sra" \
    --max-size 200G

echo "Starting fasterq-dump:"
date

while read -r SRR; do
    echo "Converting $SRR"
    fasterq-dump "$PROJECT/sra/$SRR" \
        --split-files \
        --threads 8 \
        --outdir "$PROJECT/fastq" \
        --temp "$PROJECT/tmp"
done < "$SRR_LIST"

echo "Compressing FASTQs:"
date

gzip "$PROJECT"/fastq/*.fastq

echo "Done:"
date

ls -lh "$PROJECT/fastq"
