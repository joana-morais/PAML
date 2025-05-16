################################################################################################
# Pal2Nal   																				   #	
# Joana Morais																				   #
# Based on: https://github.com/abacus-gene/paml-tutorial/tree/main/positive-selection/00_data  #
################################################################################################

#!/bin/bash
#SBATCH -J HOX_Pal2Nal
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1G
#SBATCH --time=10-00:00:00
#SBATCH --constraint=no_gpu
#SBATCH -o /scratch/joanamorais/jobs/01_OUTandERR/HOX_Pal2Nal.out
#SBATCH -e /scratch/joanamorais/jobs/01_OUTandERR/HOX_Pal2Nal.err

# Configuration options
TEST_MODE=false
TEST_GENE="HOXB1"  # Default test gene set to HOXB1

# Define input and output directories
INPUT_BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/01a_TranslatorX"
OUTPUT_BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/02_Pal2Nal"
PAL2NAL_SCRIPT="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/02_Pal2Nal/pal2nal.pl"

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
    
    # Check for required input files
    local working_dir="$gene_dir/01_working_dir"
    local protein_file="$working_dir/${gene_name}_PROT_TranslatorX_clustalw.fasta"
    local dna_file="$working_dir/${gene_name}_CDS_DNA_TranslatorX_clustalw.fasta"
    
    if [ ! -f "$protein_file" ] || [ ! -f "$dna_file" ]; then
        echo "Error: Required input files for $gene_name not found:"
        [ ! -f "$protein_file" ] && echo "  Missing: $protein_file"
        [ ! -f "$dna_file" ] && echo "  Missing: $dna_file"
        return
    fi
    
    # Create output directory for the gene
    local output_dir="$OUTPUT_BASE_DIR/$gene_name"
    mkdir -p "$output_dir"
    
    # Set output file path
    local output_file="$output_dir/${gene_name}_TranslatorX_Pal2Nal.fasta"
    
    # Run pal2nal with protein file first, then DNA file
    echo "Running pal2nal for $gene_name..."
    echo "  Protein alignment: $protein_file"
    echo "  DNA alignment: $dna_file"
    perl "$PAL2NAL_SCRIPT" "$protein_file" "$dna_file" -output fasta > "$output_file"
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "Successfully processed $gene_name with pal2nal"
        
        # Verify the output file exists and is not empty
        if [ -s "$output_file" ]; then
            echo "Created $output_file ($(wc -l < "$output_file") lines)"
        else
            echo "Warning: Output file $output_file is empty or not created properly"
        fi
    else
        echo "Error processing $gene_name with pal2nal"
    fi
    
    echo "----------------------------------------"
}

# Main execution logic
if [ "$TEST_MODE" = true ]; then
    echo "TEST MODE: Processing only gene $TEST_GENE with pal2nal"
    
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
    echo "FULL MODE: Processing all HOX genes in $INPUT_BASE_DIR"
    
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




#!/bin/bash
#SBATCH -J HOX_MAFFT_Pal2Nal
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem=2G
#SBATCH --time=10-00:00:00
#SBATCH --constraint=no_gpu
#SBATCH -o /scratch/joanamorais/jobs/01_OUTandERR/HOX_MAFFT_Pal2Nal.out
#SBATCH -e /scratch/joanamorais/jobs/01_OUTandERR/HOX_MAFFT_Pal2Nal.err

# Configuration options
TEST_MODE=false
TEST_GENE="HOXB1"  # Default test gene set to HOXB1

# Define input and output directories
INPUT_BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/01b_MAFFT"
OUTPUT_BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/02_Pal2Nal"
PAL2NAL_SCRIPT="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/02_Pal2Nal/pal2nal.pl"

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
    
    # Check for required input files
    local working_dir="$gene_dir/01_working_dir"
    local protein_file="$working_dir/${gene_name}_PROT_MAFFT.fasta"
    local dna_file="$working_dir/${gene_name}_CDS_DNA_MAFFT.fasta"
    
    if [ ! -f "$protein_file" ] || [ ! -f "$dna_file" ]; then
        echo "Error: Required input files for $gene_name not found:"
        [ ! -f "$protein_file" ] && echo "  Missing: $protein_file"
        [ ! -f "$dna_file" ] && echo "  Missing: $dna_file"
        return
    fi
    
    # Create output directory for the gene
    local output_dir="$OUTPUT_BASE_DIR/$gene_name"
    mkdir -p "$output_dir"
    
    # Set output file path
    local output_file="$output_dir/${gene_name}_MAFFT_Pal2Nal.fasta"
    
    # Run pal2nal with protein file first, then DNA file
    echo "Running pal2nal for $gene_name (MAFFT alignments)..."
    echo "  Protein alignment: $protein_file"
    echo "  DNA alignment: $dna_file"
    perl "$PAL2NAL_SCRIPT" "$protein_file" "$dna_file" -output fasta > "$output_file"
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "Successfully processed $gene_name MAFFT alignments with pal2nal"
        
        # Verify the output file exists and is not empty
        if [ -s "$output_file" ]; then
            echo "Created $output_file ($(wc -l < "$output_file") lines)"
        else
            echo "Warning: Output file $output_file is empty or not created properly"
        fi
    else
        echo "Error processing $gene_name MAFFT alignments with pal2nal"
    fi
    
    echo "----------------------------------------"
}

# Main execution logic
if [ "$TEST_MODE" = true ]; then
    echo "TEST MODE: Processing only gene $TEST_GENE MAFFT alignments with pal2nal"
    
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
    echo "FULL MODE: Processing all HOX genes MAFFT alignments in $INPUT_BASE_DIR"
    
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
    
    echo "All HOX genes MAFFT alignments processed. Check the output directories for results."
fi