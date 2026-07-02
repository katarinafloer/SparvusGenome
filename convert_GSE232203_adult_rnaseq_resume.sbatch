#!/bin/bash
#SBATCH --job-name=convert_GSE232203
#SBATCH --partition=cpu
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/convert_GSE232203_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/convert_GSE232203_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

PROJECT=/work/pi_lmangiamele_smith_edu/2023_adult_male_rnaseq_GSE232203
SRR_LIST=$PROJECT/runinfo/SRR_Acc_List.txt
SCRATCH_TMP=/scratch3/workspace/kfloer_smith_edu-simple/sra_tmp_GSE232203

mkdir -p "$PROJECT"/fastq "$SCRATCH_TMP"

module purge
module load sratoolkit/3.0.0

cd "$PROJECT"

echo "Starting conversion resume:"
date

while read -r SRR; do
    R1_GZ="$PROJECT/fastq/${SRR}_1.fastq.gz"
    R2_GZ="$PROJECT/fastq/${SRR}_2.fastq.gz"
    R1_FQ="$PROJECT/fastq/${SRR}_1.fastq"
    R2_FQ="$PROJECT/fastq/${SRR}_2.fastq"

    if [[ -s "$R1_GZ" && -s "$R2_GZ" ]]; then
        echo "Skipping $SRR because gzipped paired FASTQs already exist"
        continue
    fi

    if [[ -s "$R1_FQ" && -s "$R2_FQ" ]]; then
        echo "Compressing existing FASTQs for $SRR"
        gzip "$R1_FQ" "$R2_FQ"
        continue
    fi

    echo "Converting $SRR"
    date

    fasterq-dump "$PROJECT/sra/$SRR" \
        --split-files \
        --threads 8 \
        --outdir "$PROJECT/fastq" \
        --temp "$SCRATCH_TMP" \
        --disk-limit 1000G \
        --disk-limit-tmp 1000G

    echo "Compressing $SRR"
    gzip "$R1_FQ" "$R2_FQ"

    echo "Finished $SRR"
    date
done < "$SRR_LIST"

echo "Final FASTQ files:"
find "$PROJECT/fastq" -type f -name '*.fastq.gz' | sort | xargs ls -lh

echo "Done:"
date
