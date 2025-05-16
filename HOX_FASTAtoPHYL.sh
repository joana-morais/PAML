#!/bin/bash
#SBATCH -J HOX_FASTAtoPHYL
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1G
#SBATCH --time=10-00:00:00
#SBATCH --constraint=no_gpu
#SBATCH -o /scratch/joanamorais/jobs/01_OUTandERR/HOX_FASTAtoPHYL.out
#SBATCH -e /scratch/joanamorais/jobs/01_OUTandERR/HOX_FASTAtoPHYL.err

# Configuration
BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML"
INPUT_DIR="${BASE_DIR}/02_Pal2Nal"
OUTPUT_DIR="${BASE_DIR}/03_Phylip_files"
SCRIPTS_DIR="${BASE_DIR}/000_scripts"
TEST_MODE=true
TEST_GENE="HOXB1"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Create one-line FASTA to PHYLIP converter script
cat > "${SCRIPTS_DIR}/fasta_to_oneline_to_phylip.pl" << 'EOF'
#!/usr/bin/perl
use strict;
use warnings;

# Get input file path from command line argument
my $input_file = $ARGV[0];
die "Usage: $0 <fasta_file>\n" unless $input_file && -f $input_file;

# Generate output filenames
my $base_name = $input_file;
$base_name =~ s/\.fasta$//;
my $oneline_file = "${base_name}_one_line.fa";
my $phylip_file = "${base_name}_one_line.phy";

# Process FASTA to one-line FASTA
open(IN_FASTA, "<$input_file") or die "Cannot open $input_file: $!";
open(OUT_ONELINE, ">$oneline_file") or die "Cannot create $oneline_file: $!";

my @oneline_fasta;
my $sequence = '';
my $linecount = 1;

while (my $line = <IN_FASTA>) {
    chomp $line;
    if ($line =~ /^>/) {  # If the line is a header line
        if ($linecount == 1) {  # If this is the first header line,
            push(@oneline_fasta, $line);  # just add the header to the oneline_fasta array
            $linecount++;  # Increase the linecount
        }
        else {
            push(@oneline_fasta, $sequence);  # print the concatenated sequence to output
            push(@oneline_fasta, $line);  # print the new header to oneline_fasta
            $sequence = '';  # empty the sequence string
        }
    }
    else {  # not a header line? - must be sequence
        $sequence .= $line;  # append additional sequence
    }
}

# Add the last sequence
push(@oneline_fasta, $sequence);

# Write one-line FASTA to file
foreach my $element (@oneline_fasta) {
    print OUT_ONELINE "$element\n";
}
close OUT_ONELINE;
close IN_FASTA;

# Now convert one-line FASTA to PHYLIP format
open(IN_ONELINE, "<$oneline_file") or die "Cannot open $oneline_file: $!";
open(OUT_PHYLIP, ">$phylip_file") or die "Cannot create $phylip_file: $!";

# First, read the entire file to count sequences and get sequence length
my @headers;
my @sequences;
my $seq_count = 0;
my $seq_length = 0;

while (my $line = <IN_ONELINE>) {
    chomp $line;
    if ($line =~ /^>(.*)/) {
        push @headers, $1;  # Store header without '>'
        $seq_count++;
    }
    else {
        push @sequences, $line;
        # Set sequence length if this is the first sequence
        $seq_length = length($line) if $seq_count == 1;
    }
}

# Write PHYLIP header and sequences
print OUT_PHYLIP "$seq_count $seq_length\n";

for (my $i = 0; $i < $seq_count; $i++) {
    print OUT_PHYLIP "$headers[$i]\t$sequences[$i]\n";
}

close IN_ONELINE;
close OUT_PHYLIP;

print "Converted $input_file to one-line FASTA and PHYLIP format\n";
print "Created $oneline_file and $phylip_file\n";
EOF

# Make the script executable
chmod +x "${SCRIPTS_DIR}/fasta_to_oneline_to_phylip.pl"

# Function to process a single gene directory
process_gene_dir() {
    local gene_dir="$1"
    local gene_name=$(basename "$gene_dir")

    echo "Processing gene directory: $gene_name"

    # Create output directory for this gene
    local gene_output_dir="${OUTPUT_DIR}/${gene_name}"
    mkdir -p "$gene_output_dir"

    # Find all .fasta files in this directory
    local fasta_files=("$gene_dir"/*.fasta)

    if [ ${#fasta_files[@]} -eq 0 ] || [ ! -f "${fasta_files[0]}" ]; then
        echo "No .fasta files found in $gene_dir"
        return
    fi

    # Process each .fasta file
    for fasta_file in "${fasta_files[@]}"; do
        echo "Converting $(basename "$fasta_file")..."

        # Run the Perl script to convert FASTA to one-line FASTA and then to PHYLIP
        perl "${SCRIPTS_DIR}/fasta_to_oneline_to_phylip.pl" "$fasta_file"

        # Move the resulting PHYLIP file to the output directory
        local base_name=$(basename "$fasta_file" .fasta)
        local phylip_file="${gene_dir}/${base_name}_one_line.phy"

        if [ -f "$phylip_file" ]; then
            # Copy to output directory
            cp "$phylip_file" "${gene_output_dir}/"
            echo "Copied $(basename "$phylip_file") to ${gene_output_dir}/"
        else
            echo "Error: PHYLIP file not created for $fasta_file"
        fi
    done

    echo "----------------------------------------"
}

# Main script execution
echo "Starting FASTA to PHYLIP conversion"

if [ "$TEST_MODE" = true ]; then
    echo "TEST MODE: Processing only $TEST_GENE"

    # Process only the test gene
    test_gene_dir="${INPUT_DIR}/${TEST_GENE}"

    if [ ! -d "$test_gene_dir" ]; then
        echo "Error: Test gene directory $test_gene_dir does not exist"
        exit 1
    fi

    process_gene_dir "$test_gene_dir"

    echo "Test completed. Check ${OUTPUT_DIR}/${TEST_GENE} for results."
else
    echo "FULL MODE: Processing all HOX gene directories"

    # Process all HOX* directories
    for gene_dir in "${INPUT_DIR}"/HOX*; do
        if [ -d "$gene_dir" ]; then
            process_gene_dir "$gene_dir"
        fi
    done

    echo "All HOX gene directories processed. Check $OUTPUT_DIR for results."
fi

echo "Conversion completed successfully"