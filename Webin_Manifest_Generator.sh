#!/bin/bash

# Usage check
if [ $# -ne 1 ]; then
  echo "Usage: $0 <path/to/manifest.tsv>"
  exit 1
fi

MANIFEST="$1"

if [ ! -f "$MANIFEST" ]; then
  echo "ERROR: File not found: $MANIFEST"
  exit 1
fi

# Output directory = same directory as input manifest
OUTDIR="$(dirname "$MANIFEST")"

awk -F'\t' '
NR==1 { next }   # skip header

{
  sample=$1
  study=$2
  name=$3
  platform=$4
  lib_source=$5
  lib_selection=$6
  lib_strategy=$7
  fq1=$8
  fq2=$9

  outfile=sprintf("%s/%s.manifest", "'"$OUTDIR"'", sample)

  print "STUDY\t"study                 > outfile
  print "NAME\t"name                   >> outfile
  print "SAMPLE\t"sample               >> outfile
  print "INSTRUMENT\t"platform           >> outfile
  print "LIBRARY_SOURCE\t"lib_source   >> outfile
  print "LIBRARY_SELECTION\t"lib_selection >> outfile
  print "LIBRARY_STRATEGY\t"lib_strategy   >> outfile
  print "FASTQ\t"fq1                   >> outfile
  print "FASTQ\t"fq2                   >> outfile
}
' "$MANIFEST"

echo "✅ Single-sample ENA manifests created in:"
echo "   $OUTDIR"
