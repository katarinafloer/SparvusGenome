#!/bin/bash
#SBATCH --job-name=sparvus_egapx_resume
#SBATCH --partition=cpu
#SBATCH --qos=long
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=14-00:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/egapx_resume_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/egapx_resume_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

set -euo pipefail
umask 002

PROJECT=/scratch3/workspace/kfloer_smith_edu-simple/egapx_sparvus
EGAPX=$PROJECT/egapx

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

echo "Resume started: $(date)"
echo "Driver node: $(hostname)"

cd "$EGAPX"
bash "$PROJECT/output/nextflow/resume.sh"

echo "Resume finished: $(date)"
