# it reorganizes FASTA sequence files from a species-based organization to a gene-based organization, making comparative genomic analysis more straightforward


#######

#The parse_fasta_header() function extracts gene and species information from FASTA headers that #follow the format "GENENAME_SPECIES".
#The read_fasta_files() function:

#Processes all FASTA files in the input directory
#Parses headers to identify genes and species
#Groups sequences by gene and then by species
#Tracks processing statistics


#The write_gene_files() function:

#Creates a new FASTA file for each gene
#Includes all species sequences for that gene in the file
vUses a consistent naming format for sequence headers


#The main() function defines input/output directories and orchestrates the reorganization process.



import os
from collections import defaultdict

def parse_fasta_header(header):
    """Extract gene name and species from FASTA header"""
    # Split the header to get the first part (e.g., 'HOXC4_CalSin')
    gene_species = header.split()[0].strip('>')
    
    # Split by underscore to separate gene and species
    parts = gene_species.split('_')
    if len(parts) < 2:
        print(f"Warning: Unexpected header format: {header}")
        return None, None
    
    gene, species = parts[0], parts[1]
    
    # Standardize HOX gene names to uppercase
    gene = gene.upper()
    if gene.startswith('HOX') or gene.startswith('hox'):
        # Handle different case variations
        gene = 'HOX' + gene[3:]
        
    return gene, species

def read_fasta_files(directory):
    """Read all FASTA files in directory and organize sequences by gene"""
    # Use defaultdict to automatically create new dictionaries for each gene
    gene_sequences = defaultdict(dict)
    processed_files = 0
    empty_files = 0
    
    # Process each FASTA file in the directory
    for filename in os.listdir(directory):
        # Skip non-FASTA files
        if not filename.endswith(('.fa', '.fasta')):
            continue
            
        with open(os.path.join(directory, filename)) as f:
            current_header = ''
            current_sequence = []
            file_empty = True
            
            for line in f:
                line = line.strip()
                if line.startswith('>'):
                    # Save the previous sequence if it exists
                    if current_header:
                        gene, species = parse_fasta_header(current_header)
                        if gene and species:  # Only process if we got valid gene/species
                            gene_sequences[gene][species] = ''.join(current_sequence)
                            file_empty = False
                            
                    # Start new sequence
                    current_header = line
                    current_sequence = []
                elif line:  # Sequence line
                    current_sequence.append(line)
                    
            # Save the last sequence in the file
            if current_header:
                gene, species = parse_fasta_header(current_header)
                if gene and species:
                    gene_sequences[gene][species] = ''.join(current_sequence)
                    file_empty = False
                    
            processed_files += 1
            if file_empty:
                empty_files += 1
                print(f"Warning: No valid sequences found in {filename}")
    
    # Print processing summary statistics
    print(f"\nProcessing Summary:")
    print(f"Total files processed: {processed_files}")
    print(f"Empty or invalid files: {empty_files}")
    print(f"Genes found: {len(gene_sequences)}")
    print("\nGenes processed:")
    for gene in sorted(gene_sequences.keys()):
        print(f"- {gene}: {len(gene_sequences[gene])} species")
        
    return gene_sequences

def write_gene_files(gene_sequences, output_directory):
    """Write new FASTA files organized by gene"""
    # Create output directory if it doesn't exist
    os.makedirs(output_directory, exist_ok=True)
    
    # Process each gene and its sequences
    for gene, sequences in gene_sequences.items():
        if not sequences:  # Skip if no sequences for this gene
            print(f"Warning: No sequences found for {gene}")
            continue
            
        # Create one file per gene
        output_file = os.path.join(output_directory, f"{gene}.fasta")
        with open(output_file, 'w') as f:
            # Write each species sequence for this gene
            for species, sequence in sequences.items():
                f.write(f">{gene}_{species}\n{sequence}\n")
                
        print(f"Created {output_file} with {len(sequences)} sequences")

def main():
    # Directory containing your input FASTA files
    input_directory = "/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS"
    
    # Directory where new gene-based FASTA files will be saved
    output_directory = "/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/protein_separated_fasta"
    
    print(f"Starting to process files from {input_directory}")
    
    # Process the files
    gene_sequences = read_fasta_files(input_directory)
    write_gene_files(gene_sequences, output_directory)

if __name__ == "__main__":
    main()