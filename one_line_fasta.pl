# This is a Perl script that converts a multi-line FASTA file to a "one-line" FASTA format. In standard FASTA files, sequence data often spans multiple lines after each header. This script reformats the file so that each sequence appears on a single line after its header.


#!/usr/bin/perl
# This is a Perl shebang line indicating the interpreter to use

use strict;    # Enforces good programming practices like declaring variables
use warnings;  # Enables warnings to catch common problems

# Opens the input file provided as first command line argument
# Dies with error message if opening fails
open (INP_FASTA, "<$ARGV[0]") or die "Cannot open $ARGV[0] file: $!";

## Open the output file to save the reference genome ID matching the
## input strain
my $cut_name = $ARGV[0];
# Extracts base filename by removing everything after the first period
$cut_name =~ s/\..*//;
# Creates output filename by adding "_one_line.fa" to the base filename
my $out_name = "$cut_name" . "_one_line.fa";
# Opens the output file in append mode, dies if it fails
open(OUT, ">>$out_name") or die "Cannot create the output file: $!";

my @oneline_fasta;  # Array to store the processed FASTA entries
my $sequence = "";  # Variable to accumulate sequence data
my $linecount = 1;  # Counter to track which header we're processing

# Processes the input file line by line
while (<INP_FASTA>){
    chomp;  # Removes the newline character from current line
    
    if (m/^>/){  # Checks if line starts with ">" (FASTA header)
        if ($linecount == 1){  # If this is the first header we've seen
            push (@oneline_fasta, $_);  # Add header to output array
            $linecount++;  # Increment the line counter
        } 
        else{  # If this is any subsequent header
            push (@oneline_fasta, $sequence);  # Add accumulated sequence to output
            push (@oneline_fasta, $_);  # Add new header to output
            $sequence = '';  # Reset sequence accumulator for next entry
        } 
    } 
    else{  # If not a header line, it must be sequence data
        chomp;  # Remove newline (redundant since already chomped above)
        $sequence .= $_;  # Append this line to the accumulated sequence
    } 
}

# After processing all lines, add the final sequence to the output array
push (@oneline_fasta, $sequence);

# Write each element in the oneline_fasta array to the output file
foreach my $element (@oneline_fasta){ 
    print OUT "$element\n"; 
} 

# Close both input and output files
close OUT; 
close INP_FASTA;