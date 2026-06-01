#!/bin/bash
#SBATCH --job-name=fcs_adaptor
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/%j.fcs_adaptor.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/%j.fcs_adaptor.err

set -euo pipefail

module load apptainer/latest

export APPTAINER_CACHEDIR=/work/pi_lmangiamele_smith_edu/.apptainer/cache
mkdir -p "$APPTAINER_CACHEDIR"

export PATH=/home/kfloer_smith_edu/bin:$PATH

FCS_DIR=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/contamination_check/fcs
ASSEMBLY=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/assembly_output/sparvus_primary_contigs.fa
OUTDIR=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm/contamination_check/fcs_adaptor_out

cd "$FCS_DIR"

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

bash dist/run_fcsadaptor.sh \
  --fasta-input "$ASSEMBLY" \
  --output-dir "$OUTDIR" \
  --container-engine singularity \
  --image "$FCS_DIR/fcs-adaptor.sif" \
  --euk

