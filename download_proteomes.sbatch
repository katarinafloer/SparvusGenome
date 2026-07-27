#!/bin/bash
#SBATCH --job-name=proteome_download
#SBATCH --partition=cpu
#SBATCH --qos=long
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=0-06:00:00
#SBATCH --output=/home/kfloer_smith_edu/assembly/job_logs/proteome_download_%j.out
#SBATCH --error=/home/kfloer_smith_edu/assembly/job_logs/proteome_download_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kfloer@smith.edu

# Downloads reference proteomes for OrthoFinder from NCBI FTP.
# Panel: 3 ranids (closest relatives), 1 pyxicephalid, 1 bufonid,
#        Xenopus (best-curated anuran), human + mouse (outgroups for symbol transfer).
# Verify GCF accessions at https://www.ncbi.nlm.nih.gov/datasets/genome/ if any fail.

PROTEOME_DIR=/scratch3/workspace/kfloer_smith_edu-simple/orthofinder_sparvus/proteomes
mkdir -p ${PROTEOME_DIR}

# Copy Staurois parvus proteome and rename for clean OrthoFinder output
cp /scratch3/workspace/kfloer_smith_edu-simple/egapx_sparvus/output_tadpole_plus_adult/complete.proteins.faa \
    ${PROTEOME_DIR}/Staurois_parvus.faa

# ── Download function ──────────────────────────────────────────────────────────
# Uses NCBI datasets CLI if available, falls back to FTP wget
download_proteome() {
    local ACCESSION=$1
    local SPECIES=$2
    local OUTFILE=${PROTEOME_DIR}/${SPECIES}.faa

    echo "Downloading ${SPECIES} (${ACCESSION}) at $(date)"

    if command -v datasets &>/dev/null; then
        datasets download genome accession ${ACCESSION} \
            --include protein \
            --filename /tmp/${SPECIES}.zip \
            && unzip -p /tmp/${SPECIES}.zip \
                "ncbi_dataset/data/${ACCESSION}/*.faa" \
                > ${OUTFILE} \
            && rm /tmp/${SPECIES}.zip
    else
        # Direct FTP fallback — construct path from accession digits
        DIGITS=$(echo ${ACCESSION} | grep -oP '\d+\.\d+' | tr -d '.')
        D1=${DIGITS:0:3}; D2=${DIGITS:3:3}; D3=${DIGITS:6:3}
        BASE=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/${D1}/${D2}/${D3}
        # Get assembly name from directory listing
        ASSEMBLY=$(wget -qO- ${BASE}/ | grep -oP "GCF_[^\"]+(?=/<)" | head -1)
        wget -c -O ${OUTFILE}.gz ${BASE}/${ASSEMBLY}/${ASSEMBLY}_protein.faa.gz \
            && gunzip ${OUTFILE}.gz
    fi

    if [[ -s ${OUTFILE} ]]; then
        echo "  OK: $(grep -c '^>' ${OUTFILE}) proteins"
    else
        echo "  FAILED: ${OUTFILE} is empty"
    fi
}

# ── Reference panel ───────────────────────────────────────────────────────────
# Ranidae (same family as Staurois parvus)
download_proteome GCF_905171775.1  Rana_temporaria
download_proteome GCF_002022765.2  Lithobates_catesbeianus  # Ranidae, second family member

# Dicroglossidae / Pyxicephalidae — close outgroup families
download_proteome GCF_000935625.1  Nanorana_parkeri         # Dicroglossidae
download_proteome GCF_004798865.1  Pyxicephalus_adspersus   # Pyxicephalidae, sister to Ranidae

# Bufonidae outgroup
download_proteome GCF_000349095.1  Anaxyrus_americanus

# Best-curated anuran annotation (Xenbase)
download_proteome GCF_000004195.4  Xenopus_tropicalis

# Mammalian outgroups for symbol transfer
download_proteome GCF_000001405.40 Homo_sapiens
download_proteome GCF_000001635.27 Mus_musculus

echo ""
echo "=== Proteome staging complete at $(date) ==="
echo "Files in ${PROTEOME_DIR}:"
ls -lh ${PROTEOME_DIR}
