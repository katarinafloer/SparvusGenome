#!/bin/bash
#SBATCH --job-name=eggnog_sparvus
#SBATCH --partition=cpu
#SBATCH --qos=long
#SBATCH --cpus-per-task=16
#SBATCH --mem=80G
#SBATCH --time=3-00:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/eggnog_sparvus_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/eggnog_sparvus_%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@uchicago.edu

# eggNOG-mapper v2 on Staurois parvus proteome.
# Input:  complete.proteins.faa from EGAPx output (~23,550 proteins)
# Output: sparvus.emapper.annotations TSV — gene symbol (Preferred_name),
#         GO terms, KEGG orthologs, COG category, taxonomic scope
#
# Prerequisite: run download_eggnog_db.sbatch first.
# To resume an interrupted run, add --resume to the emapper.py call.

SCRATCH=/scratch3/workspace/kfloer_smith_edu-simple
INPUT=${SCRATCH}/egapx_sparvus/output_tadpole_plus_adult/complete.proteins.faa
EGGNOG_DB=${SCRATCH}/eggnog_db
OUT_DIR=${SCRATCH}/eggnog_sparvus
OUT_PREFIX=sparvus

CONDA_BASE=/modules/opt/linux-ubuntu24.04-x86_64/miniforge3/24.7.1
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate /work/pi_lmangiamele_smith_edu/kfloer_smith_edu/.conda/envs/eggnog_env

mkdir -p ${OUT_DIR}

echo "eggNOG-mapper started at $(date)"
echo "Input:    ${INPUT}"
echo "Database: ${EGGNOG_DB}"
echo "Output:   ${OUT_DIR}/${OUT_PREFIX}.*"
echo "CPUs:     ${SLURM_CPUS_PER_TASK}"

emapper.py \
    -i ${INPUT} \
    --itype proteins \
    -m diamond \
    --sensmode sensitive \
    --data_dir ${EGGNOG_DB} \
    --cpu ${SLURM_CPUS_PER_TASK} \
    -o ${OUT_PREFIX} \
    --output_dir ${OUT_DIR} \
    --tax_scope auto \
    --target_orthologs all \
    --go_evidence all \
    --pfam_realign none \
    --override

echo "eggNOG-mapper finished at $(date)"

# Quick summary of annotation coverage
echo ""
echo "=== Annotation coverage ==="
ANNOT=${OUT_DIR}/${OUT_PREFIX}.emapper.annotations

# Total annotated (non-header lines)
TOTAL=$(grep -v "^#" ${ANNOT} | wc -l)
# Genes with a Preferred_name (gene symbol), column 13
NAMED=$(grep -v "^#" ${ANNOT} | awk -F'\t' '$13 != "-" && $13 != ""' | wc -l)
# Genes with at least one GO term, column 10
WITH_GO=$(grep -v "^#" ${ANNOT} | awk -F'\t' '$10 != "-" && $10 != ""' | wc -l)
# Genes with KEGG KO, column 12
WITH_KEGG=$(grep -v "^#" ${ANNOT} | awk -F'\t' '$12 != "-" && $12 != ""' | wc -l)

echo "Total annotated:      ${TOTAL}"
echo "With gene symbol:     ${NAMED}"
echo "With GO terms:        ${WITH_GO}"
echo "With KEGG KO:         ${WITH_KEGG}"
