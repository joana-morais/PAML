#!/bin/bash
#SBATCH -J HOX_FASTAtoPHYL
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=2G
#SBATCH --time=10-00:00:00
#SBATCH --constraint=no_gpu
#SBATCH -o /scratch/joanamorais/jobs/01_OUTandERR/HOX_FASTAtoPHYL.out
#SBATCH -e /scratch/joanamorais/jobs/01_OUTandERR/HOX_FASTAtoPHYL.err

# Configuration options
TEST_MODE=false
TEST_GENE="HOXB1"  # Default test gene set to HOXB1

# Define input and output directories
INPUT_BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/02_Pal2Nal"
OUTPUT_BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/03_Phylip_files"
FASTA_TO_PHYL_SCRIPT="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/000_scripts/FASTAtoPHYL.pl"

# Create the base output directory if it doesn't exist
mkdir -p "$OUTPUT_BASE_DIR"

# Function to process a single gene
process_gene() {
    local gene_dir="$1"
    local gene_name=$(basename "$gene_dir")

    # Skip if the gene doesn't start with HOX
    if [[ ! "$gene_name" =~ ^HOX ]]; then
        echo "Skipping non-HOX gene: $gene_name"
        return
    fi

    echo "Processing gene: $gene_name"

    # Check for required input file
    local input_file="$gene_dir/${gene_name}_TranslatorX_Pal2Nal.fasta"

    if [ ! -f "$input_file" ]; then
        echo "Error: Required input file for $gene_name not found: $input_file"
        return
    fi

    # Create output directory for the gene
    local output_dir="$OUTPUT_BASE_DIR/$gene_name"
    mkdir -p "$output_dir"

    # Set temporary working directory for the conversion
    local temp_dir=$(mktemp -d)

    # Run FASTAtoPHYL.pl in the temp directory
    echo "Running FASTAtoPHYL.pl for $gene_name..."
    echo "  Input file: $input_file"

    # Change to temp directory for the conversion
    cd "$temp_dir"

    # Run the conversion
    perl "$FASTA_TO_PHYL_SCRIPT" "$input_file"

    # Check if the command was successful
    if [ $? -eq 0 ]; then
        # Look for the output file with standard .phy extension
        local temp_output_file="${gene_name}_TranslatorX_Pal2Nal.phy"

        if [ -f "$temp_output_file" ]; then
            # Move the file to the final destination with the desired naming
            local final_output_file="$output_dir/${gene_name}_TranslatorX_Pal2Nal_one_line.fa.phy"
            mv "$temp_output_file" "$final_output_file"

            echo "Successfully converted $gene_name to PHYLIP format"
            echo "Created $final_output_file ($(wc -l < "$final_output_file") lines)"
        else
            echo "Warning: Expected output file not found in temp directory"
            # List files in temp directory for debugging
            echo "Files in temp directory:"
            ls -la
        fi
    else
        echo "Error converting $gene_name to PHYLIP format"
    fi

    # Clean up temp directory
    rm -rf "$temp_dir"

    echo "----------------------------------------"
}

# Main execution logic
if [ "$TEST_MODE" = true ]; then
    echo "TEST MODE: Processing only gene $TEST_GENE with FASTAtoPHYL.pl"

    # Process only the test gene
    gene_dir="$INPUT_BASE_DIR/$TEST_GENE"

    # Check if the test gene directory exists
    if [ ! -d "$gene_dir" ]; then
        echo "Error: Test gene directory $gene_dir does not exist."
        exit 1
    fi

    process_gene "$gene_dir"

    echo "Test completed. Check the output directory for results."
else
    echo "FULL MODE: Processing all HOX genes with FASTAtoPHYL.pl"

    # Check if the input directory exists and is not empty
    if [ ! -d "$INPUT_BASE_DIR" ] || [ -z "$(ls -A "$INPUT_BASE_DIR")" ]; then
        echo "Error: Input directory $INPUT_BASE_DIR does not exist or is empty."
        exit 1
    fi

    # Process all gene directories that start with HOX
    for gene_dir in "$INPUT_BASE_DIR"/HOX*; do
        if [ -d "$gene_dir" ]; then
            process_gene "$gene_dir"
        fi
    done

    echo "All HOX genes processed. Check the output directories for results."
fi