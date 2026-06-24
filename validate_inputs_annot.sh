#!/bin/bash
#SBATCH --job-name=sparvus_validate
#SBATCH --partition=cpu
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/validate_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/validate_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

PROJECT=/scratch3/workspace/kfloer_smith_edu-simple/egapx_sparvus
READDIR=/work/pi_lmangiamele_smith_edu/03_26_flut_yale_rnaseq
READLIST=$PROJECT/input/short_reads.txt
ASSEMBLY=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/assembly_output/sparvus_primary_contigs.ncbi.fa

echo "Checking manifest paths..."

while read -r sample path; do
    if [[ ! -r "$path" ]]; then
        echo "ERROR: unreadable FASTQ: $path"
        exit 1
    fi
done < "$READLIST"

echo "Checking compressed FASTQ files..."

find "$READDIR" -maxdepth 1 -type f -name '*.fastq.gz' -print0 |
    xargs -0 -n 1 -P 4 gzip -t

echo "All FASTQ gzip files passed."

echo "Checking assembly and calculating basic statistics..."

awk '
/^>/ {
    contigs++
    id=$1
    sub(/^>/, "", id)
    if (seen[id]++)
        duplicates++
    next
}
{
    gsub(/[[:space:]]/, "")
    bases += length($0)
}
END {
    printf "Contigs: %d\n", contigs
    printf "Total bases: %d\n", bases
    printf "Duplicate sequence IDs: %d\n", duplicates

    if (contigs == 0 || bases == 0 || duplicates > 0)
        exit 1
}
' "$ASSEMBLY"

echo "All input validation checks passed."
