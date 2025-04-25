
#This Python script processes a multi-sequence FASTA file, splitting it into separate files—one for each sequence—with filenames derived from sequence headers while preserving the original input file.

#!/bin/bash

# Configuration - update these paths to the FASTA files containing HOX gene sequences for each species
SPECIES1_FOLDER="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/CDS_hox_sequences_extracted_DNA_CS_with_NAMES_species.fasta"
SPECIES2_FOLDER="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/CDS_hox_sequences_extracted_DNA_TO_with_NAMES_species.fasta"
SPECIES3_FOLDER="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/CDS_hox_sequences_extracted_DNA_SM_with_NAMES_species.fasta"

# Create arrays to store species file paths and names for easy iteration
SPECIES_FOLDERS=("$SPECIES1_FOLDER" "$SPECIES2_FOLDER" "$SPECIES3_FOLDER")
SPECIES_NAMES=("Calyptommatus" "Tretioscincus" "Salvator")

# Function to standardize HOX gene naming format
# Extracts the HOX gene identifier and converts to uppercase
normalize_gene_name() {
  echo "$1" | grep -o -i -E "HOX[A-Za-z]?[0-9]+[a-z]?" | tr '[:lower:]' '[:upper:]'
}

# Create temporary files to store HOX gene names for each species
for i in {0..2}; do
  touch "/tmp/hox_genes_${SPECIES_NAMES[$i]}.txt"
done

# Process each species to extract HOX gene names from FASTA files
for i in {0..2}; do
  folder="${SPECIES_FOLDERS[$i]}"
  species="${SPECIES_NAMES[$i]}"
  echo "Analyzing $species ($folder)..."
  
  # Find all FASTA files (with .fa or .fasta extensions)
  find "$folder" -name "*.fasta" -o -name "*.fa" | while read fasta_file; do
    # Extract FASTA headers (lines starting with ">")
    grep "^>" "$fasta_file" | while read -r header; do
      # Normalize the gene name and save if it's a HOX gene
      gene_name=$(normalize_gene_name "$header")
      if [[ ! -z "$gene_name" ]]; then
        echo "$gene_name" >> "/tmp/hox_genes_${species}.txt"
      fi
    done
  done
  
  # Sort gene names and remove duplicates for each species
  sort -u "/tmp/hox_genes_${species}.txt" > "/tmp/hox_genes_${species}_sorted.txt"
  echo "Found $(wc -l < "/tmp/hox_genes_${species}_sorted.txt") HOX genes in $species"
  echo ""
done

# Combine all species' HOX genes into a master list
cat /tmp/hox_genes_*_sorted.txt | sort -u > /tmp/all_hox_genes.txt
total_genes=$(wc -l < "/tmp/all_hox_genes.txt")
echo "Total unique HOX genes found across all species: $total_genes"
echo ""

# Generate a presence/absence matrix for all HOX genes across species
echo "HOX Gene Presence/Absence Matrix:"
echo "--------------------------------"

# Print header row with species names
printf "%-10s" "Gene"
for species in "${SPECIES_NAMES[@]}"; do
  printf "%-10s" "$species"
done
echo ""

# For each gene, check its presence in each species
while read -r gene; do
  printf "%-10s" "$gene"
  for species in "${SPECIES_NAMES[@]}"; do
    if grep -q "^$gene$" "/tmp/hox_genes_${species}_sorted.txt"; then
      printf "%-10s" "Present"
    else
      printf "%-10s" "MISSING"
    fi
  done
  echo ""
done < /tmp/all_hox_genes.txt
echo ""

# Check for inconsistent naming conventions across species
echo "Naming Consistency Check:"
echo "------------------------"

# Identify potential naming variations for the same gene
for gene in $(cat /tmp/all_hox_genes.txt); do
  # Extract the base gene name (without paralog letters)
  base_gene=$(echo "$gene" | grep -o -E "HOX[A-Z]?[0-9]+")
  if [[ ! -z "$base_gene" ]]; then
    # Find all variations of this base gene
    variations=$(grep -h -i "^$base_gene[a-z]\?$" /tmp/hox_genes_*_sorted.txt | sort -u)
    var_count=$(echo "$variations" | wc -l)
    
    # Report if multiple naming variations exist
    if [[ $var_count -gt 1 ]]; then
      echo "Found potential naming variations for $base_gene:"
      echo "$variations" | sed 's/^/  - /'
      echo ""
    fi
  fi
done

# Remove temporary files
rm /tmp/hox_genes_*.txt /tmp/all_hox_genes.txt