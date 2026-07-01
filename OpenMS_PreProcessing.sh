#!/bin/bash
set -euo pipefail

# Help message function
print_help() {
    echo ""
    echo "🔬 OpenMS Preprocessing Pipeline (Positive Ion Mode)"
    echo ""
    echo "USAGE:"
    echo "  $0 <input_folder>"
    echo ""
    echo "DESCRIPTION:"
    echo "  This script runs a full preprocessing pipeline for LC-MS/MS metabolomics data"
    echo "  in positive ion mode using OpenMS tools. It processes all .mzML files in the given"
    echo "  folder through the following steps:"
    echo ""
    echo "  1. Peak Picking (using PeakPickerHiRes)"
    echo "  2. Feature Detection (using FeatureFinderCentroided)"
    echo "  3. Retention Time Alignment (using MapAlignerPoseClustering)"
    echo "  4. Feature Linking (using FeatureLinkerUnlabeledQT)"
    echo "  5. Export of feature table (using TextExporter)"
    echo ""
    echo "ARGUMENTS:"
    echo "  <input_folder>     Path to the folder containing .mzML files (positive ion mode only)"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help         Show this help message and exit"
    echo ""
    echo "OUTPUT:"
    echo "  - Aligned .featureXML files"
    echo "  - consensus.consensusXML file with linked features"
    echo "  - features.tsv table with intensity data for statistical analysis"
    echo ""
    echo "EXAMPLE:"
    echo "  bash $0 /path/to/positive_mode_files"
    echo ""
    echo "NOTE:"
    echo "  • Only run this on positive ion data from the same experimental batch."
    echo "  • For negative ion mode, run a separate instance of the script."
    echo ""
    exit 0
}

# Check for -h or --help
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    print_help
fi

# Check input argument
if [ "$#" -ne 1 ]; then
    echo "❗ Error: Missing input folder."
    echo "Use -h for help."
    exit 1
fi

# Set working directory
input_dir="$1"

# Check if folder exists
if [ ! -d "$input_dir" ]; then
    echo "❌ Error: Folder not found: $input_dir"
    exit 1
fi

cd "$input_dir"

echo "📁 Working in folder: $input_dir"
echo "🔄 Starting preprocessing pipeline for positive ion mode..."

# Step 1: Peak picking
echo "🧪 Step 1: Peak Picking..."
for file in *.mzML; do
    base="${file%.mzML}"
    PeakPickerHiRes -in "$file" -out "${base}_pp.mzML"
done

# Step 2: Feature finding
echo "🧬 Step 2: Feature Finding..."
for file in *_pp.mzML; do
    base="${file%_pp.mzML}"
    FeatureFinderCentroided -in "$file" -out "${base}.featureXML"
done

# Step 3: Prepare for alignment
echo "🗂️ Preparing input/output lists for alignment..."
input_files=()
output_files=()

for file in *.featureXML; do
    input_files+=("$file")
    base="${file%.featureXML}"
    output_files+=("${base}_aligned.featureXML")
done

# Step 4: RT alignment
echo "⏱️ Step 3: Retention Time Alignment..."
MapAlignerPoseClustering \
    -in "${input_files[@]}" \
    -out "${output_files[@]}"

# Step 5: Feature linking
echo "🔗 Step 4: Feature Linking..."
FeatureLinkerUnlabeledQT \
    -in "${output_files[@]}" \
    -out consensus.consensusXML

# Step 6: Export features
echo "📤 Step 5: Exporting feature table..."
TextExporter -in consensus.consensusXML -out features.tsv

echo "✅ Done! Output saved to: $input_dir/features.tsv"
