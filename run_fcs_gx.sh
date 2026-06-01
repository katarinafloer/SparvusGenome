#!/bin/bash
#SBATCH --job-name=fcs_gx
#SBATCH --cpus-per-task=16
#SBATCH --mem=512G
#SBATCH --time=36:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/%j.fcs_gx.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/%j.fcs_gx.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail

module load apptainer/latest

export PATH=/home/kfloer_smith_edu/bin:$PATH
export APPTAINER_CACHEDIR=/work/pi_lmangiamele_smith_edu/.apptainer/cache
mkdir -p "$APPTAINER_CACHEDIR"

FCS_DIR=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/contamination_check/fcs
ASSEMBLY=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/assembly_output/sparvus_primary_contigs.fa
GXDB=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/contamination_check/fcs_gx_db
OUTDIR=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/contamination_check/fcs_gx_out
IMAGE=${FCS_DIR}/fcs-gx.sif

# Replace this with confirmed NCBI Taxonomy ID for Staurois parvus
TAXID=386267

cd "$FCS_DIR"

mkdir -p "$OUTDIR"

echo "Starting FCS-GX at $(date)"
echo "Assembly: $ASSEMBLY"
echo "GXDB: $GXDB"
echo "Output: $OUTDIR"
echo "TaxID: $TAXID"

python3 dist/fcs.py \
  --image "$IMAGE" \
  screen genome \
  --fasta "$ASSEMBLY" \
  --out-dir "$OUTDIR" \
  --gx-db "$GXDB" \
  --tax-id "$TAXID"

echo "Finished FCS-GX at $(date)"
