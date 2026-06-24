#!/bin/bash
#SBATCH --job-name=sparvus_egapx
#SBATCH --partition=cpu
#SBATCH --qos=long
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=14-00:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/egapx_driver_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/egapx_driver_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail
umask 002

PROJECT=/scratch3/workspace/kfloer_smith_edu-simple/egapx_sparvus
EGAPX=$PROJECT/egapx
INPUT_YAML=$PROJECT/input/sparvus.yaml

module purge
module load apptainer/latest
module load nextflow/24.04.3

source "$EGAPX/venv/bin/activate"

export APPTAINER_CACHEDIR="$PROJECT/container_cache"
export APPTAINER_TMPDIR="$PROJECT/tmp"
export SINGULARITY_CACHEDIR="$PROJECT/container_cache"
export SINGULARITY_TMPDIR="$PROJECT/tmp"
export NXF_SINGULARITY_CACHEDIR="$PROJECT/container_cache"
export NXF_HOME="$PROJECT/.nextflow"
export TMPDIR="$PROJECT/tmp"

export SINGULARITY_BINDPATH="/scratch3:/scratch3,/work:/work,/home:/home"
export APPTAINER_BINDPATH="$SINGULARITY_BINDPATH"

mkdir -p "$NXF_HOME" "$PROJECT/output" "$PROJECT/work"

echo "Started: $(date)"
echo "Driver node: $(hostname)"
echo "EGAPx: $(python "$EGAPX/ui/egapx.py" -V)"
nextflow -version
singularity --version

cd "$EGAPX"

python ui/egapx.py \
    "$INPUT_YAML" \
    --data-version egapxsupportdata_20251017 \
    -e slurm \
    -w "$PROJECT/work" \
    -o "$PROJECT/output"

echo "Finished: $(date)"
