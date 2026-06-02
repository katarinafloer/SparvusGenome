#!/bin/bash

# =========================
# Project directories
# =========================

SCRATCH_DIR=/scratch3/workspace/kfloer_smith_edu-simple/sparvus_hifiasm
PROJ_DIR=/home/kfloer_smith_edu/assembly
READS_DIR=/work/pi_lmangiamele_smith_edu/yale_hifi_03_26/hifi_reads
OUTPUT_DIR=${SCRATCH_DIR}/assembly_output

LOG_DIR=${PROJ_DIR}/job_logs
SCRIPT_DIR=${PROJ_DIR}/scripts

CONTAM_DIR=${SCRATCH_DIR}/contamination_check
CONTAM_LOG_DIR=${LOG_DIR}/contamination_check

FINAL_QC_DIR=${SCRATCH_DIR}/final_ncbi_qc

# =========================
# Input files
# =========================

HIFI_READS=${READS_DIR}/sparvus_hifi.fastq.gz

# Original hifiasm primary contig FASTA
RAW_ASSEMBLY=${OUTPUT_DIR}/sparvus_primary_contigs.fa

# FCS-adaptor output; sequence-identical to RAW_ASSEMBLY except FCS formatting
ADAPTOR_CLEAN_ASSEMBLY=${OUTPUT_DIR}/sparvus_primary_contigs.fcs_adaptor_clean.fa

# Final NCBI-clean assembly with ptg003819l removed
FINAL_ASSEMBLY=${OUTPUT_DIR}/sparvus_primary_contigs.ncbi.fa

# Main assembly variable used by downstream scripts
ASSEMBLY=${FINAL_ASSEMBLY}

# =========================
# Contamination screening outputs
# =========================

FCS_ADAPTOR_DIR=${CONTAM_DIR}/fcs_adaptor_out
FCS_ADAPTOR_REPORT=${FCS_ADAPTOR_DIR}/fcs_adaptor_report.txt

FCS_GX_DIR=${CONTAM_DIR}/fcs_gx_out
FCS_GX_REPORT=${FCS_GX_DIR}/sparvus_primary_contigs.386267.fcs_gx_report.txt
FCS_GX_TAXONOMY_REPORT=${FCS_GX_DIR}/sparvus_primary_contigs.386267.taxonomy.rpt

GC_COV_SUBSET_DIR=${CONTAM_DIR}/gc_coverage_subset
GC_LENGTH_TABLE=${GC_COV_SUBSET_DIR}/contig_gc_length.tsv
GC_COV_TABLE=${GC_COV_SUBSET_DIR}/hifi_subset_vs_assembly.coverage.tsv

REMOVED_CONTIG=ptg003819l
REMOVED_CONTIG_LENGTH=19494
REMOVED_CONTIG_REASON="FCS-GX contaminant: anml:nematodes, Oscheius tipulae"

# =========================
# BUSCO files/directories
# =========================

BUSCO_DOWNLOADS=${OUTPUT_DIR}/busco_downloads
BUSCO_LINEAGE=vertebrata_odb10

# Existing original assembly BUSCO output
BUSCO_ORIGINAL_DIR=${OUTPUT_DIR}/busco_primary_vertebrata_256G_8c_metauk

# Final clean assembly BUSCO output
BUSCO_FINAL_OUT=busco_ncbi_clean_vertebrata
BUSCO_FINAL_DIR=${FINAL_QC_DIR}/${BUSCO_FINAL_OUT}

# =========================
# Software / environments
# =========================

CONDA_SH=/modules/opt/linux-ubuntu24.04-x86_64/miniforge3/24.7.1/etc/profile.d/conda.sh

ASSEMBLY_ENV=/work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/assembly_env
BUSCO_ENV=/work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/busco_env

# Legacy variable, if older scripts expect it
CONDA_ENV=assembly_env

# =========================
# Assembly parameters
# =========================

THREADS=32
BUSCO_THREADS=16
MEMORY=256G

ASSEMBLY_PREFIX=sparvus_hifiasm

# =========================
# NCBI / taxonomy
# =========================

TAXID=386267
ORGANISM="Staurois parvus"
