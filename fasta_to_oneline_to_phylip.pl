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
    print OUT_PHYLIP "$headers[$i]\n$sequences[$i]\n";
}

close IN_ONELINE;
close OUT_PHYLIP;

print "Converted $input_file to one-line FASTA and PHYLIP format\n";
print "Created $oneline_file and $phylip_file\n";