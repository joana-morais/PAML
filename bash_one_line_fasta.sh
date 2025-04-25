#!/bin/bash
#SBATCH -J teste
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --time=12:00:00
#SBATCH --constraint=no_gpu
#SBATCH --output=/scratch/joanamorais/jobs/01_OUTandERR/teste.%j.out
#SBATCH --error=/scratch/joanamorais/jobs/01_OUTandERR/teste.%j.err

# Define input and output directories
input_dir="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/protein_separated_fasta"
output_dir="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/protein_separated_fasta/protein_separated_fasta_one_line"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all FASTA files in the input directory
for fasta_file in "$input_dir"/*.fasta; do
    # Get the filename without path
    filename=$(basename "$fasta_file")

    # Run the script to convert to one-line format
    /scratch/joanamorais/jobs/03_Hox/analysis/HOX/DNA_CDS/protein_separated_fasta/one_line_fasta.pl "$fasta_file"

    # Move the new file to the output directory
    mv "${fasta_file%.fasta}_one_line.fa" "$output_dir/$filename"
done

echo "Conversion completed! Output saved in $output_dir"