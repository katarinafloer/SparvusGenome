#!/bin/bash
#SBATCH --job-name=final_stats
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=24:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/%j.final_stats.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/%j.final_stats.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

source ~/assembly/scripts/sparvus_config.sh
source "$CONDA_SH"

mkdir -p "$FINAL_QC_DIR"

echo "Final assembly: $FINAL_ASSEMBLY"

if [[ ! -f "$FINAL_ASSEMBLY" ]]; then
    echo "ERROR: Final assembly does not exist: $FINAL_ASSEMBLY"
    echo "Do not recreate it here. Run remove_contaminant.sh first if needed."
    exit 1
fi

if grep -q "$REMOVED_CONTIG" "$FINAL_ASSEMBLY"; then
    echo "ERROR: Removed contaminant still present: $REMOVED_CONTIG"
    exit 1
fi

echo "Confirmed contaminant is absent: $REMOVED_CONTIG"

echo "Running seqkit stats..."
conda activate "$ASSEMBLY_ENV"
seqkit stats -a "$FINAL_ASSEMBLY" > "$FINAL_QC_DIR/sparvus_primary_contigs.ncbi.seqkit_stats.txt"
conda deactivate

echo "Running assembly-stats and BUSCO..."
conda activate "$BUSCO_ENV"

assembly-stats "$FINAL_ASSEMBLY" > "$FINAL_QC_DIR/sparvus_primary_contigs.ncbi.assembly_stats.txt"

cd "$FINAL_QC_DIR"

busco \
  -i "$FINAL_ASSEMBLY" \
  -o "$BUSCO_FINAL_OUT" \
  -l "$BUSCO_LINEAGE" \
  -m genome \
  --cpu "$BUSCO_THREADS" \
  --offline \
  --download_path "$BUSCO_DOWNLOADS"

echo "Done final stats at $(date)"
echo "Final assembly: $FINAL_ASSEMBLY"
echo "QC directory: $FINAL_QC_DIR"
