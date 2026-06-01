#!/bin/bash

# =========================
# Project directories
# =========================

SCRATCH_DIR=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm
PROJ_DIR=/home/kfloer_smith_edu/assembly
READS_DIR=/work/pi_lmangiamele_smith_edu/yale_hifi_03_26/hifi_reads
OUTPUT_DIR=${SCRATCH_DIR}/assembly_output

LOG_DIR=${PROJ_DIR}/job_logs

#ASSEMBLY=${OUTPUT_DIR}/sparvus_primary_contigs.fa
ASSEMBLY=${SCRATCH_DIR}/assembly_output/sparvus_primary_contigs.fcs_adaptor_clean.fa

CONTAM_DIR=${SCRATCH_DIR}/contamination_check
CONTAM_LOG_DIR=${LOG_DIR}/contamination_check

# =========================
# Input files
# =========================

HIFI_READS=${READS_DIR}/sparvus_hifi.fastq.gz

# =========================
# Software / environments
# =========================

CONDA_SH=/modules/opt/linux-ubuntu24.04-x86_64/miniforge3/24.7.1/etc/profile.d/conda.sh

CONDA_ENV=assembly_env

# =========================
# Assembly parameters
# =========================

THREADS=32
MEMORY=256G

ASSEMBLY_PREFIX=sparvus_hifiasm
