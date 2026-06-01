#!/bin/bash
#SBATCH --job-name=fcs_gx_db
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/%j.fcs_gx_db.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/%j.fcs_gx_db.err

set -euo pipefail

module load apptainer/latest

export PATH=/home/kfloer_smith_edu/bin:$PATH
export APPTAINER_CACHEDIR=/work/pi_lmangiamele_smith_edu/.apptainer/cache
mkdir -p "$APPTAINER_CACHEDIR"

FCS_DIR=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/contamination_check/fcs
GXDB=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/contamination_check/fcs_gx_db
IMAGE=${FCS_DIR}/fcs-gx.sif
MFT=https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/database/latest/all.manifest

cd "$FCS_DIR"

mkdir -p "$GXDB"

python3 dist/fcs.py \
  --image "$IMAGE" \
  db get \
  --mft "$MFT" \
  --dir "$GXDB"

python3 dist/fcs.py \
  --image "$IMAGE" \
  db check \
  --mft "$MFT" \
  --dir "$GXDB"
