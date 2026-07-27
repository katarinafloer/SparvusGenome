#!/bin/bash
#SBATCH --job-name=orthofinder_sparvus
#SBATCH --partition=cpu
#SBATCH --qos=long
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=3-00:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/orthofinder_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/orthofinder_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

PROTEOME_DIR=/scratch3/workspace/kfloer_smith_edu-simple/orthofinder_sparvus/proteomes
OUT_DIR=/scratch3/workspace/kfloer_smith_edu-simple/orthofinder_sparvus

CONDA_BASE=/modules/opt/linux-ubuntu24.04-x86_64/miniforge3/24.7.1
source "${CONDA_BASE}/etc/profile.d/conda.sh"

conda activate \
  /work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/orthofinder_env

echo "OrthoFinder started at $(date)"
echo "Node: $(hostname)"
echo "CPUs: ${SLURM_CPUS_PER_TASK}"

mapfile -t FASTAS < <(
    find "${PROTEOME_DIR}" \
        -maxdepth 1 \
        -type f \
        -name '*.faa' \
        -size +0c \
        | sort
)

if (( ${#FASTAS[@]} < 3 )); then
    echo "ERROR: Fewer than three nonempty proteomes found." >&2
    exit 1
fi

echo "Proteomes: ${#FASTAS[@]} species"

total=0
for fasta in "${FASTAS[@]}"; do
    count=$(grep -c '^>' "${fasta}")
    total=$((total + count))

    printf "%-40s %8d proteins\n" \
        "$(basename "${fasta}")" \
        "${count}"
done

echo "Total proteins: ${total}"

RESULT_ROOT="${OUT_DIR}/results"

if [[ -e "${RESULT_ROOT}" ]]; then
    echo "ERROR: Output path already exists: ${RESULT_ROOT}" >&2
    echo "Rename or remove it before starting a new clean run." >&2
    exit 1
fi

orthofinder \
    -f "${PROTEOME_DIR}" \
    -t "${SLURM_CPUS_PER_TASK}" \
    -a 8 \
    -S diamond \
    -o "${RESULT_ROOT}"

echo "OrthoFinder finished successfully at $(date)"

RESULTS=$(find "${RESULT_ROOT}" \
    -type d \
    -name 'Results_*' \
    -printf '%T@ %p\n' \
    | sort -nr \
    | head -n 1 \
    | cut -d' ' -f2-)

if [[ -n "${RESULTS}" && -d "${RESULTS}" ]]; then
    echo
    echo "Results: ${RESULTS}"

    STATS="${RESULTS}/Comparative_Genomics_Statistics/Statistics_Overall.tsv"

    if [[ -s "${STATS}" ]]; then
        echo "=== Summary ==="
        cat "${STATS}"
    fi
fi
