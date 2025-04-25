# This is a Python script for bioinformatics analysis that creates codon alignments of HOX genes from protein alignments. 
# Pal2Nal script 
# check: https://github.com/liaochenlanruo/PAL2NAL/blob/master/pal2nal.pl

#!/usr/bin/env python3
# This is a Python shebang line indicating this script should be run with Python 3

import os
import subprocess
from pathlib import Path
# Importing necessary modules for file operations, subprocess calls, and path handling

def read_fasta_headers(file_path):
    """
    Read all headers from a FASTA file.
    Returns a list of headers without the '>' character.
    """
    headers = []
    with open(file_path) as f:
        for line in f:
            if line.startswith('>'):
                # Finds header lines (starting with '>') and strips off the '>' character
                headers.append(line[1:].strip())
    return headers

def extract_matching_sequences(protein_file, cds_dirs):
    """
    Extract CDS sequences that match protein headers exactly from multiple directories.
    Returns a dictionary mapping headers to CDS file paths.
    """
    protein_headers = read_fasta_headers(protein_file)
    matching_cds = {}

    # For each protein header, search all CDS directories
    for header in protein_headers:
        hox_gene = header.split('_')[0]  # Extracts gene name (like HOXA1)
        species_id = header.split('_')[1]  # Gets species identifier (CalSin, SalMer, etc.)

        # Look for matching CDS files in all directories
        found = False
        for cds_dir in cds_dirs:
            if found:
                break

            for cds_file in Path(cds_dir).glob(f"{hox_gene}*.fasta"):
                # For each potential matching CDS file, check if it contains the header
                cds_headers = read_fasta_headers(cds_file)
                if header in cds_headers:
                    matching_cds[header] = str(cds_file)
                    found = True
                    break

        if not found:
            print(f"Warning: No matching CDS found for protein header '{header}'")

    return matching_cds

def create_temp_files(protein_file, matching_cds, temp_dir):
    """
    Create temporary files with only the matching sequences in the correct order.
    """
    os.makedirs(temp_dir, exist_ok=True)
    temp_protein = Path(temp_dir) / "temp_protein.fasta"
    temp_cds = Path(temp_dir) / "temp_cds.fasta"

    # Create a temporary protein file with only the matching sequences
    with open(temp_protein, 'w') as prot_out, open(protein_file) as prot_in:
        writing = False
        current_header = ""
        for line in prot_in:
            if line.startswith('>'):
                current_header = line[1:].strip()
                writing = current_header in matching_cds  # Only write sequences that have matching CDS
            if writing:
                prot_out.write(line)

    # Create a temporary CDS file with sequences in same order as protein file
    with open(temp_cds, 'w') as cds_out:
        for header in matching_cds:
            cds_file = matching_cds[header]
            writing = False
            with open(cds_file) as cds_in:
                for line in cds_in:
                    if line.startswith('>'):
                        writing = line[1:].strip() == header  # Find the matching sequence
                    if writing:
                        cds_out.write(line)

    return temp_protein, temp_cds

def process_hox_alignments(base_protein_dir, cds_dirs, output_dir):
    """
    Process all HOX protein alignments and their corresponding CDS sequences.
    """
    os.makedirs(output_dir, exist_ok=True)
    temp_dir = Path(output_dir) / "temp"
    os.makedirs(temp_dir, exist_ok=True)

    # Find all aligned protein files
    protein_dir = Path(base_protein_dir)
    for hox_dir in protein_dir.glob("HOX*"):
        # Look for the aligned fasta file
        aligned_files = list(hox_dir.glob("*_aligned.fasta"))

        if not aligned_files:
            print(f"No aligned file found in {hox_dir}")
            continue

        protein_file = aligned_files[0]
        hox_gene = hox_dir.name
        print(f"\nProcessing {hox_gene}...")

        # Get matching CDS sequences from all directories
        matching_cds = extract_matching_sequences(protein_file, cds_dirs)

        if not matching_cds:
            print(f"No matching CDS sequences found for {hox_gene}")
            continue

        # Create temporary files with matching sequences
        temp_protein, temp_cds = create_temp_files(protein_file, matching_cds, temp_dir)

        # Output file path
        output_path = Path(output_dir) / f"{hox_gene}_codon_alignment.fasta"

        # Run pal2nal (a tool that converts protein alignments to codon alignments)
        try:
            cmd = [
                "pal2nal.pl",  # External tool to convert protein alignment to codon alignment
                str(temp_protein),
                str(temp_cds),
                "-output", "fasta",
                "-codontable", "1"  # Standard genetic code
            ]

            with open(output_path, 'w') as outfile:
                result = subprocess.run(
                    cmd,
                    stdout=outfile,
                    stderr=subprocess.PIPE,
                    check=True,
                    text=True
                )
            print(f"Successfully processed {hox_gene} with {len(matching_cds)} sequences")
            print("Matched sequences:", list(matching_cds.keys()))

        except subprocess.CalledProcessError as e:
            print(f"Error processing {hox_gene}: {e.stderr}")

        # Clean up temporary files
        temp_protein.unlink()
        temp_cds.unlink()

    # Clean up temporary directory
    os.rmdir(temp_dir)

if __name__ == "__main__":
    # Define your directories
    PROTEIN_ALN_DIR = "/scratch/joanamorais/jobs/03_Hox/analysis/HOX/ALIGNMENTS/PROTEIN"

    # List of CDS directories for different species
    CDS_DIRS = [
        "/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/CS_separated",
        "/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/SM_separated",
        "/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/TO_separated"
    ]

    OUTPUT_DIR = "codon_alignments"

    # Run the alignment
    process_hox_alignments(PROTEIN_ALN_DIR, CDS_DIRS, OUTPUT_DIR)
    print("\nCodon alignment process complete!")