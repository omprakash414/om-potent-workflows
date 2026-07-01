#!/bin/bash

# USAGE: bash Get_Species_Names_Taxonkit.sh <TaxID> <Taxdump_Path>

if [ $# -ne 2 ]; then
    echo "Usage: $0 <TaxID> <Taxdump_Path>"
    exit 1
fi

TAXID="$1"
DUMP_DIR="$2"
OUT_PREFIX="species_list_${TAXID}"

# Validate taxdump folder
if [ ! -d "$DUMP_DIR" ]; then
    echo "[ERROR] Taxdump directory not found: $DUMP_DIR"
    exit 1
fi

echo "[INFO] Using TaxID: $TAXID"
echo "[INFO] Using taxonomy data from: $DUMP_DIR"

# Step 1: Get all descendant taxids
echo "[STEP 1] Listing all descendant taxids..."
taxonkit list --data-dir "$DUMP_DIR" --ids "$TAXID" > all_descendants.txt

# Step 2: Extract taxids only
echo "[STEP 2] Extracting TaxIDs..."
awk '{print $1}' all_descendants.txt > taxids.txt

# Step 3: Get lineage with ranks
echo "[STEP 3] Getting lineage with ranks..."
taxonkit lineage --data-dir "$DUMP_DIR" -r taxids.txt > lineage_with_ranks.txt

# Step 4: Filter species
echo "[STEP 4] Filtering species..."
awk -F'\t' '$3 ~ /species/' lineage_with_ranks.txt > "${OUT_PREFIX}.tsv"

# Step 5: Extract species names
awk -F'\t' '{n=split($2,a,";"); print a[n]}' "${OUT_PREFIX}.tsv" > "${OUT_PREFIX}_names.txt"


echo "[DONE] Species info written to:"
echo "       → ${OUT_PREFIX}.tsv (TaxID, Name, Lineage, Rank)"
echo "       → ${OUT_PREFIX}_names.txt (Only species names)"
