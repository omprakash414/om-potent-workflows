#!/bin/bash
# prepare_ligands_for_docking.sh
# Usage: ./prepare_ligands_for_docking.sh /path/to/folder sdf|pdb
set -euo pipefail

folder="$1"
input_ext="$2"   # e.g. sdf or pdb

if [[ -z "$folder" || -z "$input_ext" ]]; then
  echo "Usage: $0 /path/to/folder input_ext"
  exit 1
fi

if [[ ! -d "$folder" ]]; then
  echo "Folder not found: $folder"
  exit 1
fi

# Check for Open Babel
if ! command -v obabel &>/dev/null; then
  echo "Open Babel (obabel) is required. Install via:"
  echo "  conda install -c conda-forge openbabel"
  exit 1
fi

# Check for prepare_ligand4.py
if command -v prepare_ligand4.py &>/dev/null; then
  USE_PREPARE_LIGAND=true
else
  USE_PREPARE_LIGAND=false
  echo "Note: prepare_ligand4.py not found. Using Open Babel fallback (Gasteiger)."
fi

echo "Processing *.$input_ext files in $folder ..."

for inpath in "$folder"/*."$input_ext"; do
  [[ -f "$inpath" ]] || continue
  fname=$(basename "$inpath")
  base="${fname%.*}"
  echo "----"
  echo "Input: $fname"

  tmp_pdb="$folder/${base}_tmp.pdb"

  # Step A: Prepare intermediate PDB with hydrogens
  if [[ "$input_ext" == "pdb" ]]; then
    # PDB already has 3D coords → skip --gen3d
    obabel "$inpath" -O "$tmp_pdb" -h >/dev/null 2>&1 \
      || { echo "Error processing $fname"; continue; }
  else
    # SDF or other formats need 3D coords
    obabel "$inpath" -O "$tmp_pdb" -h --gen3d >/dev/null 2>&1 \
      || { echo "Error converting $fname -> tmp pdb"; continue; }
  fi

  final_pdbqt="$folder/${base}.pdbqt"

  # Step B: Convert to PDBQT with charges
  if $USE_PREPARE_LIGAND; then
    prepare_ligand4.py -l "$tmp_pdb" -o "$final_pdbqt" >/dev/null 2>&1 \
      || { echo "prepare_ligand4.py failed for $base"; continue; }
  else
    obabel "$tmp_pdb" -O "$final_pdbqt" -h --partialcharge gasteiger >/dev/null 2>&1 \
      || { echo "Open Babel conversion failed for $base"; continue; }
  fi

  # Step C: Optional — check total charge
  chk_mol2="$folder/${base}_chk.mol2"
  obabel "$final_pdbqt" -O "$chk_mol2" >/dev/null 2>&1 || true

  charge_sum=0
  if [[ -f "$chk_mol2" ]]; then
    charge_sum=$(awk '/@<TRIPOS>ATOM/{p=1; next} /@<TRIPOS>BOND/{p=0} p{print}' "$chk_mol2" \
      | awk '{s+=$NF} END{printf "%0.6f", s}')
    rm -f "$chk_mol2"
  fi

  rm -f "$tmp_pdb"

  echo "Output: $final_pdbqt"
  echo "Total partial charge: $charge_sum"
done

echo "Done."
