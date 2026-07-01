#!/usr/bin/env bash
set -euo pipefail

GENOME_DIR="$1"           # e.g., fungi_db
DB_DIR="$2"               # e.g., kraken2_fungi_db
GROUP="$3"                # e.g., fungi

mkdir -p "$DB_DIR"

echo "📥 Downloading taxonomy..."
kraken2-build --download-taxonomy --db "$DB_DIR" --threads 60

echo "🔍 Parsing assembly summary files to map ftp_path to taxid..."
REFSEQ_SUMMARY="refseq_${GROUP}_assembly_summary.txt"
GENBANK_SUMMARY="genbank_${GROUP}_assembly_summary.txt"

# Combine both summaries
awk -F '\t' '!/^#/ { print $20 "\t" $6 }' "$REFSEQ_SUMMARY" "$GENBANK_SUMMARY" > all_ftp_to_taxid.tsv

echo "📦 Processing genomes in: $GENOME_DIR"

for genome in "$GENOME_DIR"/*.fna.gz; do
  base=$(basename "$genome" _genomic.fna.gz)
  
  # Try to find its ftp path in the summary
  ftp_line=$(zgrep -m1 '^>' "$genome" || echo "")
  match=$(grep "$base" all_ftp_to_taxid.tsv || echo "")

  if [[ -n "$match" ]]; then
    taxid=$(echo "$match" | cut -f2)
  else
    echo "⚠️  Could not find taxid for $base, defaulting to fungi (taxid 4751)"
    taxid=4751
  fi

  echo "➕ Adding $base with taxid $taxid"

  tmp_fa="tmp_${base}.fna"
  zcat "$genome" | sed "s/^>/>kraken:taxid|$taxid|/" > "$tmp_fa"

  kraken2-build --add-to-library "$tmp_fa" --db "$DB_DIR" --no-masking

  rm "$tmp_fa"
done

echo "🧱 Building Kraken2 database..."
kraken2-build --build --db "$DB_DIR" --threads 32

echo "✅ Kraken2 DB built in: $DB_DIR"
