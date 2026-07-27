#!/bin/bash
#SBATCH --job-name=eggnog_db_download
#SBATCH --partition=cpu
#SBATCH --qos=long
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=1-00:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/eggnog_db_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/eggnog_db_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kfloer@uchicago.edu

# Downloads eggNOG 5.0 database (~54 GB total) to scratch.
# Must complete before running run_eggnog_mapper.sbatch.
# Runtime: ~1-3 hours depending on network.

EGGNOG_DB=/scratch3/workspace/kfloer_smith_edu-simple/eggnog_db

CONDA_BASE=/modules/opt/linux-ubuntu24.04-x86_64/miniforge3/24.7.1
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate /work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/eggnog_env

mkdir -p ${EGGNOG_DB}

echo "Downloading eggNOG database to ${EGGNOG_DB} at $(date)"

# Downloads eggnog.db (~48 GB) and eggnog_proteins.dmnd (~4 GB)
download_eggnog_data.py \
    --data_dir ${EGGNOG_DB} \
    -y

echo "Download complete at $(date)"
du -sh ${EGGNOG_DB}
