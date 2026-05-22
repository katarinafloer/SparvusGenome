#!/bin/bash
#SBATCH --job-name=sparvus_busco
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=256G
#SBATCH --time=24:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/%x.%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/%x.%j.err

set -euo pipefail

# =========================
# Load config
# =========================

source /home/kfloer_smith_edu/assembly/scripts/sparvus_config.sh

# =========================
# BUSCO settings
# =========================

BUSCO_OUT=busco_primary_vertebrata_256G_8c_metauk

ASSEMBLY_FA=${OUTPUT_DIR}/sparvus_primary_contigs.fa

LINEAGE=vertebrata_odb10

# =========================
# Safety checks
# =========================

[[ -f "$CONDA_SH" ]] || {
    echo "ERROR: conda.sh not found"
    exit 1
}

[[ -f "$ASSEMBLY_FA" ]] || {
    echo "ERROR: Assembly FASTA not found"
    exit 1
}

# =========================
# Activate BUSCO environment
# =========================

source "$CONDA_SH"

conda activate busco_env

# =========================
# Tool checks
# =========================

command -v busco >/dev/null 2>&1 || {
    echo "ERROR: BUSCO not found"
    exit 1
}

echo "Using BUSCO:"
which busco

echo "Starting BUSCO"
date

cd "$OUTPUT_DIR"

# =========================
# Run BUSCO
# =========================

busco \
    -i "$ASSEMBLY_FA" \
    -l "$LINEAGE" \
    -m genome \
    --metaeuk \
    -o "$BUSCO_OUT" \
    -c 8

echo "BUSCO finished"
date
