#!/bin/bash

# ========================
# Help Function
# ========================
show_help() {
  echo ""
  echo "Usage:"
  echo "  bash $0 <reads_list.txt> <kraken2_db> <NUM_THREADS> <SAMPLE_NAME_PATTERN> <MODE>"
  echo ""
  echo "Description:"
  echo "  This script runs Kraken2 classification using either paired-end or single-end FASTQ files."
  echo ""
  echo "Positional Arguments:"
  echo "  reads_list.txt        Text file with FASTQ file paths."
  echo "                         - For paired-end: two columns (R1 R2)"
  echo "                         - For single-end: one column (R1 only)"
  echo "  kraken2_db            Path to the Kraken2 database"
  echo "  NUM_THREADS           Number of threads to use"
  echo "  SAMPLE_NAME_PATTERN   Pattern to strip from read file name (e.g. '_R1_paired.fastq.gz' or .fastq.gz or fq.gz)"
  echo "  MODE                  'paired' or 'single'"
  echo ""
  echo "Example:"
  echo "  bash $0 reads_list.txt ./kraken2_db 32 _R1_paired.fastq.gz paired"
  echo "  bash $0 reads_list_single.txt ./kraken2_db 16 _trimmed.fastq.gz single"
  echo ""
  exit 0
}

# ========================
# Show Help if -h or --help is used
# ========================
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
fi

# ========================
# Input Parameters
# ========================
READS_LIST="$1"
DB_PATH="$2"
THREADS="$3"
PATTERN="$4"
MODE="$5"

# ========================
# Validate Inputs
# ========================
if [ "$#" -ne 5 ]; then
  echo "❌ Error: Incorrect number of arguments."
  echo "Use -h for help: bash $0 -h"
  exit 1
fi

if [ ! -f "$READS_LIST" ]; then
  echo "❌ Error: Reads list file '$READS_LIST' does not exist."
  exit 1
fi

if [ ! -d "$DB_PATH" ]; then
  echo "❌ Error: Kraken2 database folder '$DB_PATH' does not exist."
  exit 1
fi

if ! [[ "$THREADS" =~ ^[0-9]+$ ]]; then
  echo "❌ Error: Threads must be a positive integer."
  exit 1
fi

if [[ "$MODE" != "paired" && "$MODE" != "single" ]]; then
  echo "❌ Error: MODE must be either 'paired' or 'single'."
  exit 1
fi

# ========================
# Start Processing
# ========================
echo "🧬 Running Kraken2 classification using reads from: $READS_LIST"
echo "🧪 Database: $DB_PATH"
echo "🧵 Threads: $THREADS"
echo "⚙️ Mode: $MODE"
echo "🧾 Pattern to strip: $PATTERN"
echo ""

# ========================
# Mode: PAIRED-END
# ========================
if [[ "$MODE" == "paired" ]]; then
  while read -r R1 R2; do
    if [ ! -f "$R1" ] || [ ! -f "$R2" ]; then
      echo "⚠️  Warning: One or both files not found: $R1 $R2 — skipping."
      continue
    fi

    BASENAME=$(basename "$R1")
    SAMPLE="${BASENAME/$PATTERN/}"
    OUTPUT_DIR=$(dirname "$R1")

    echo "🔍 Processing sample: $SAMPLE (paired-end)"

    kraken2 \
      --db "$DB_PATH" \
      --paired \
      --gzip-compressed \
      --threads "$THREADS" \
      --report "${OUTPUT_DIR}/${SAMPLE}_report.txt" \
      --output "${OUTPUT_DIR}/${SAMPLE}_kraken2_output.txt" \
      "$R1" "$R2"

    echo "✅ Finished: $SAMPLE"
    echo
  done < "$READS_LIST"
fi

# ========================
# Mode: SINGLE-END
# ========================
if [[ "$MODE" == "single" ]]; then
  while read -r R1; do
    if [ ! -f "$R1" ]; then
      echo "⚠️  Warning: File not found: $R1 — skipping."
      continue
    fi

    BASENAME=$(basename "$R1")
    SAMPLE="${BASENAME/$PATTERN/}"
    OUTPUT_DIR=$(dirname "$R1")

    echo "🔍 Processing sample: $SAMPLE (single-end)"

    kraken2 \
      --db "$DB_PATH" \
      --gzip-compressed \
      --threads "$THREADS" \
      --report "${OUTPUT_DIR}/${SAMPLE}_report.txt" \
      --output "${OUTPUT_DIR}/${SAMPLE}_kraken2_output.txt" \
      "$R1"

    echo "✅ Finished: $SAMPLE"
    echo
  done < "$READS_LIST"
fi

echo "🎉 All samples processed successfully in $MODE mode."
