#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Script: its_vsearch_simple_taxonomy.sh
#
# Description:
#   Simple fungal ITS taxonomy pipeline using VSEARCH + UNITE.
#   - Paired-end reads are concatenated (NOT merged biologically)
#   - FASTQ is converted to FASTA (no quality filtering)
#   - Sequences are clustered into OTUs at 97% identity
#   - OTUs are classified against the UNITE database
#
#   Chimera detection, dereplication, and OTU tables are intentionally omitted.
#
# Requirements:
#   - vsearch
#   - pigz
#   - awk
#
# Usage:
#   bash its_vsearch_simple_taxonomy.sh samples.tsv unite.udb
#
# Inputs:
#   samples.tsv :
#     Tab-separated file with THREE columns:
#       1) Forward reads (R1.fastq.gz)
#       2) Reverse reads (R2.fastq.gz)
#       3) Sample name (no spaces)
#
#   unite.udb :
#     UNITE database indexed with:
#       vsearch --makeudb_usearch unite.fasta --output unite.udb
#
# Output:
#   For each sample:
#     sample.taxonomy.txt   → VSEARCH BLAST6 taxonomy output
#
###############################################################################

THREADS=36
PIGZ_THREADS=36

print_help() {
cat << EOF

USAGE:
  bash its_vsearch_simple_taxonomy.sh samples.tsv unite.udb

DESCRIPTION:
  This script performs fungal ITS taxonomic classification using VSEARCH.
  Paired-end reads are concatenated (not merged), clustered into OTUs,
  and classified against the UNITE database.

PIPELINE STEPS:
  1. Concatenate paired-end reads using pigz
  2. Convert FASTQ to FASTA (no quality filtering)
  3. Cluster sequences into OTUs at 97% identity
  4. Assign taxonomy using UNITE (best hit only)

INPUT FILES:
  samples.tsv
    A tab-separated file with three columns:
      column 1: forward reads (R1.fastq.gz)
      column 2: reverse reads (R2.fastq.gz)
      column 3: sample name

  unite.udb
    UNITE reference database indexed for VSEARCH
    (created using vsearch --makeudb_usearch)

OUTPUT FILES:
  sample.taxonomy.txt
    Tabular BLAST6 output containing taxonomy and alignment statistics

NOTES:
  - No chimera removal is performed
  - No dereplication is performed
  - No quality filtering is performed
  - Paired-end reads are NOT biologically merged

OPTIONS:
  -h, --help     Show this help message and exit

EOF
}

# -------------------- Argument handling --------------------

if [[ $# -lt 1 ]]; then
    print_help
    exit 1
fi

case "$1" in
    -h|--help)
        print_help
        exit 0
        ;;
esac

SAMPLES=$1
UNITE_UDB=$2

# -------------------- Sanity checks --------------------

command -v vsearch >/dev/null 2>&1 || { echo "ERROR: vsearch not found"; exit 1; }
command -v pigz >/dev/null 2>&1 || { echo "ERROR: pigz not found"; exit 1; }

[[ -f "$SAMPLES" ]] || { echo "ERROR: samples file not found"; exit 1; }
[[ -f "$UNITE_UDB" ]] || { echo "ERROR: UNITE UDB file not found"; exit 1; }

mkdir -p tmp

# -------------------- Main loop --------------------

while read -r R1 R2 SAMPLE
do
    echo "Processing sample: $SAMPLE"

    MERGED=tmp/${SAMPLE}.merged.fastq
    FILTERED=tmp/${SAMPLE}.filtered.fasta
    OTUS=tmp/${SAMPLE}.otus.fasta
    FINAL_CLASS=${SAMPLE}.taxonomy.txt

    # 1. Concatenate paired-end reads
    pigz -dc -p $PIGZ_THREADS "$R1" "$R2" > "$MERGED"

    # 2. FASTQ → FASTA (no filtering)
    awk 'NR%4==1 {gsub(/^@/,">",$0); print}
         NR%4==2 {print}' \
         "$MERGED" > "$FILTERED"

    # 3. OTU clustering (97%)
    vsearch --cluster_size "$FILTERED" \
            --id 0.97 \
            --centroids "$OTUS" \
            --sizeout \
            --threads $THREADS

    # 4. Taxonomic classification
    vsearch --usearch_global "$OTUS" \
            --db "$UNITE_UDB" \
            --id 0.97 \
            --maxaccepts 1 \
            --top_hits_only \
            --blast6out "$FINAL_CLASS" \
            --threads $THREADS

    # Cleanup
    rm -f "$MERGED" "$FILTERED" "$OTUS"

    echo "Finished sample: $SAMPLE"
    echo "----------------------------------------"

done < "$SAMPLES"

rmdir tmp 2>/dev/null || true

echo "All samples finished successfully."
