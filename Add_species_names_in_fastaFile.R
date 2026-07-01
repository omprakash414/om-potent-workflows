# Load required library
library(dplyr)

# Define paths
csv_path <- "/storage/Datasets/GENOMES_GRiD/genomes_to_transfer.csv"
fasta_folder <- "/storage/Datasets/GENOMES_GRiD/genome_files"

# Step 1: Read the CSV file
metadata <- read.csv(csv_path, stringsAsFactors = FALSE)

# Ensure the column names are clean (no trailing spaces)
colnames(metadata) <- trimws(colnames(metadata))
metadata$Genome <- trimws(metadata$Genome)
metadata$Species <- trimws(metadata$Species)

# Step 2: List all .fa files in the FASTA folder
fa_files <- list.files(path = fasta_folder, pattern = "\\.fa$", full.names = TRUE)

# Step 3: Function to process each .fa file and overwrite it
process_fasta <- function(fasta_file, metadata) {
  # Extract the filename without the path
  file_name <- basename(fasta_file)
  
  # Match the species name using the metadata
  species <- metadata %>% 
    filter(Genome == file_name) %>% 
    pull(Species)
  
  # If no match is found, print a warning and skip the file
  if (length(species) == 0) {
    warning(paste("No species found for file:", file_name))
    return(NULL)
  }
  
  # Read the .fa file
  lines <- readLines(fasta_file)
  
  # Process lines starting with ">"
  lines <- sapply(lines, function(line) {
    if (startsWith(line, ">")) {
      # Find the first space
      first_space <- regexpr(" ", line)
      if (first_space > 0) {
        # Insert ___<species> before the first space
        before_space <- substr(line, 1, first_space - 1)
        after_space <- substr(line, first_space + 1, nchar(line))
        modified_line <- paste0(before_space, "___", species, " ", after_space, "___", species)
        return(modified_line)
      } else {
        # If no space is found, just append ___<species> at the end
        return(paste0(line, "___", species))
      }
    } else {
      return(line)
    }
  })
  
  # Overwrite the original file with the modified content
  writeLines(lines, con = fasta_file)
  cat(paste("Updated file:", fasta_file, "\n"))
}

# Step 4: Wrapper to process all files
process_all_fasta <- function(fa_files, metadata) {
  for (fasta in fa_files) {
    process_fasta(fasta, metadata)
  }
  cat("All files have been updated.\n")
}

# Step 5: Execute the wrapper function
process_all_fasta(fa_files, metadata)
