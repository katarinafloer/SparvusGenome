#!/bin/bash
#SBATCH --job-name=eggnog_test
#SBATCH --partition=cpu
#SBATCH --qos=short
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/eggnog_test_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/eggnog_test_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

SCRATCH=/scratch3/workspace/kfloer_smith_edu-simple
INPUT=${SCRATCH}/eggnog_sparvus_test/sparvus_100.faa
EGGNOG_DB=${SCRATCH}/eggnog_db
OUT_DIR=${SCRATCH}/eggnog_sparvus_test/output
OUT_PREFIX=sparvus_test

CONDA_BASE=/modules/opt/linux-ubuntu24.04-x86_64/miniforge3/24.7.1
source "${CONDA_BASE}/etc/profile.d/conda.sh"

conda activate \
  /work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/eggnog_env

mkdir -p "${OUT_DIR}"

echo "Host: $(hostname)"
echo "Started: $(date)"
echo "Input proteins: $(grep -c '^>' "${INPUT}")"
echo "Database: ${EGGNOG_DB}"
echo "Output: ${OUT_DIR}/${OUT_PREFIX}.*"

[[ -s "${INPUT}" ]] || {
    echo "ERROR: Input FASTA is missing or empty" >&2
    exit 1
}

[[ -s "${EGGNOG_DB}/eggnog.db" ]] || {
    echo "ERROR: eggnog.db is missing" >&2
    exit 1
}

[[ -s "${EGGNOG_DB}/eggnog_proteins.dmnd" ]] || {
    echo "ERROR: eggnog_proteins.dmnd is missing" >&2
    exit 1
}

emapper.py \
    -i "${INPUT}" \
    --itype proteins \
    -m diamond \
    --sensmode sensitive \
    --data_dir "${EGGNOG_DB}" \
    --cpu "${SLURM_CPUS_PER_TASK}" \
    -o "${OUT_PREFIX}" \
    --output_dir "${OUT_DIR}" \
    --tax_scope auto \
    --target_orthologs all \
    --go_evidence all \
    --pfam_realign none \
    --override

ANNOT="${OUT_DIR}/${OUT_PREFIX}.emapper.annotations"

[[ -s "${ANNOT}" ]] || {
    echo "ERROR: Annotation output was not produced" >&2
    exit 1
}

echo
echo "Annotation rows:"
grep -vc '^#' "${ANNOT}"

echo
echo "Output files:"
ls -lh "${OUT_DIR}"

echo
echo "Finished: $(date)"
