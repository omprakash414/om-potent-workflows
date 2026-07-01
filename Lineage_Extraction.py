#!/usr/bin/env python3

from Bio import Entrez
import pandas as pd
import time
import sys
import os

# NCBI email
Entrez.email = "omprakashs@iiitd.ac.in"   # Replace with your email

# Check input argument
if len(sys.argv) != 2:
    print("Usage: python lineage_extraction.py <species_file.txt>")
    sys.exit(1)

input_file = sys.argv[1]

if not os.path.exists(input_file):
    print(f"Error: File not found: {input_file}")
    sys.exit(1)

# Output file name
base_name = os.path.splitext(os.path.basename(input_file))[0]
output_file = f"{base_name}_taxonomy.xlsx"

# Load species list
with open(input_file, "r") as file:
    species_list = [line.strip() for line in file if line.strip()]

taxonomy_data = []

for species in species_list:
    print(f"Processing: {species}")

    try:
        search = Entrez.esearch(
            db="taxonomy",
            term=species,
            retmode="xml"
        )
        record = Entrez.read(search)
        search.close()

        if len(record["IdList"]) > 0:

            tax_id = record["IdList"][0]

            fetch = Entrez.efetch(
                db="taxonomy",
                id=tax_id,
                retmode="xml"
            )

            tax_data = Entrez.read(fetch)[0]
            fetch.close()

            lineage_dict = {
                rank["Rank"]: rank["ScientificName"]
                for rank in tax_data["LineageEx"]
            }

            lineage_dict["Species"] = tax_data["ScientificName"]
            lineage_dict["TaxID"] = tax_id

        else:
            lineage_dict = {
                "Species": species,
                "Note": "Not found"
            }

    except Exception as e:
        lineage_dict = {
            "Species": species,
            "Note": str(e)
        }

    taxonomy_data.append(lineage_dict)

    # NCBI rate limiting
    time.sleep(0.5)

taxonomy_df = pd.DataFrame(taxonomy_data)

taxonomy_df.to_excel(output_file, index=False)

print(f"\nSaved taxonomy table to: {output_file}")