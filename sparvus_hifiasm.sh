#!/bin/bash
#SBATCH --job-name=sparvus_hifiasm
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=24:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/%x.%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/%x.%j.err

set -euo pipefail

# Load config
source /home/kfloer_smith_edu/assembly/scripts/sparvus_config.sh

# Create directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

# Safety checks
[[ -f "$CONDA_SH" ]] || {
    echo "ERROR: conda.sh not found"
    exit 1
}

[[ -f "$HIFI_READS" ]] || {
    echo "ERROR: HiFi reads not found"
    exit 1
}

# Activate conda
source "$CONDA_SH"
conda activate "$CONDA_ENV"

# Check hifiasm
command -v hifiasm >/dev/null 2>&1 || {
    echo "ERROR: hifiasm not found"
    exit 1
}

echo "Using hifiasm:"
which hifiasm
hifiasm --version || true

echo "Starting assembly"
date

cd "$OUTPUT_DIR"

hifiasm \
    -o "$ASSEMBLY_PREFIX" \
    -t "$THREADS" \
    --primary \
    "$HIFI_READS" \
    2> "${ASSEMBLY_PREFIX}.log"

echo "Done"
date
