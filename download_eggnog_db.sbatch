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

BASE_URL=http://eggnog5.embl.de/download/emapperdb-5.0.2

mkdir -p ${EGGNOG_DB}

echo "Downloading eggNOG database to ${EGGNOG_DB} at $(date)"

# eggnog.db (~48 GB uncompressed) — main annotation database
wget -c -O ${EGGNOG_DB}/eggnog.db.gz ${BASE_URL}/eggnog.db.gz \
    && echo "Decompressing eggnog.db..." \
    && gunzip ${EGGNOG_DB}/eggnog.db.gz

# eggnog.taxa — taxonomy database
wget -c -O ${EGGNOG_DB}/eggnog.taxa.tar.gz ${BASE_URL}/eggnog.taxa.tar.gz \
    && echo "Extracting eggnog.taxa..." \
    && tar -xzf ${EGGNOG_DB}/eggnog.taxa.tar.gz -C ${EGGNOG_DB} \
    && rm ${EGGNOG_DB}/eggnog.taxa.tar.gz

# eggnog_proteins.dmnd (~4 GB) — DIAMOND search database
wget -c -O ${EGGNOG_DB}/eggnog_proteins.dmnd.gz ${BASE_URL}/eggnog_proteins.dmnd.gz \
    && echo "Decompressing eggnog_proteins.dmnd..." \
    && gunzip ${EGGNOG_DB}/eggnog_proteins.dmnd.gz

echo "Download complete at $(date)"
du -sh ${EGGNOG_DB}
