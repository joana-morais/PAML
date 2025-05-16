# PAML Analysis Guide: A Comprehensive Tutorial

> *Adapted from: [paml-tutorial](https://github.com/abacus-gene/paml-tutorial/tree/main/positive-selection/00_data)*

## Table of Contents
- [Introduction](#introduction)
- [Workflow Overview](#workflow-overview)
- [Group A: Basic Analysis Steps](#group-a-basic-analysis-steps)
  - [Step 1: Sequence Alignment](#step-1-sequence-alignment)
  - [Step 2: Convert to Codon-Based Alignment](#step-2-convert-to-codon-based-alignment)
  - [Step 3-4: Format Conversion](#step-3-4-format-conversion)
  - [Step 5: Gap Analysis](#step-5-gap-analysis)
  - [Step 6: Gene Tree Preparation](#step-6-gene-tree-preparation)
  - [Step 7: Null Model (M0)](#step-7-null-model-m0)
  - [Step 8: Branch Model](#step-8-branch-model)
  - [Step 9: Branch-Site Models](#step-9-branch-site-models)
  - [Step 10: Statistical Comparison](#step-10-statistical-comparison)
- [Group B: Automated Analysis](#group-b-automated-analysis)
  - [Script 1: Gap Count and File Selection](#script-1-gap-count-and-file-selection)
  - [Script 2: Header Cleanup](#script-2-header-cleanup)
  - [Script 3: Batch M0 Model Analysis](#script-3-batch-m0-model-analysis)
  - [Script 4: Results Collection](#script-4-results-collection)
- [Directory Structure](#directory-structure)

## Introduction

This tutorial provides a step-by-step guide for detecting positive selection in genes using PAML (Phylogenetic Analysis by Maximum Likelihood). The analysis focuses on identifying selective pressure on genes by analyzing the ratio of non-synonymous to synonymous substitutions (dN/dS or ω).

## Workflow Overview

The entire workflow involves:
1. Preparing sequence alignments
2. Converting to codon-based alignments
3. Running different PAML models (M0, Branch, Branch-site)
4. Comparing models to identify positive selection

## Group A: Basic Analysis Steps

### Step 1: Sequence Alignment

Choose one of these methods:

#### Option A: TranslatorX
```
# Website method:
# Visit http://161.111.160.230/index_v5.html
# Parameters: ClustalW, Same genetic code, Guess reading frame

# OR command line method:
./translatorX.pl -i data1_unaln.fasta -p C -o clustalw_translatorx
mkdir ../alignments_clustalw
cp clustalw_translatorx.nt_ali.fasta ../alignments_clustalw/data1_nuc_clustalw_aln.fasta
cp clustalw_translatorx.aa_ali.fasta ../alignments_clustalw/data1_prot_clustalw_aln.fasta
```

#### Option B: MAFFT
```
./translatorX.pl -i data1_unaln.fasta -p F -o mafft_translatorx
```

**Important**: For both methods, save output files with appropriate naming:
- `HOXA1_CDS_DNA_MAFFT.fasta`
- `HOXA1_PROT_MAFFT.fasta`
- `HOXC9_PROT_TranslatorX.fasta`
- `HOXC9_CDS_DNA_TranslatorX.fasta`

### Step 2: Convert to Codon-Based Alignment

Use Pal2Nal to match protein alignment with DNA sequences:

```
# Basic usage
pal2nal.pl data1_prot_mafft_aln.fasta data1_nuc_mafft_aln.fasta -output fasta > output.fasta

# Example with full paths
perl pal2nal.pl /path/to/mafft_translatorx.aa_ali.fasta /path/to/mafft_translatorx.nt_ali.fasta -output fasta > /path/to/output/HOXA1_MAFFT_Pal2Nal.fasta
```

**Note**: Always include `-output fasta`

### Step 3-4: Format Conversion

Convert to one-line FASTA and then to PHYLIP format:

```
# Convert to one-line FASTA
perl one_line_fasta.pl data1pal2nal_out.fasta 

# Convert FASTA to PHYLIP
perl FASTAtoPHYL.pl file.fasta
```

### Step 5: Gap Analysis

Count gaps to select alignments with the fewest gaps:

```
# For a single file
grep -o "-" HOXA1_TranslatorX_Pal2Nal_one_line.fa | wc -l

# For multiple files
for file in /path/to/HOXA1/*.phy; do
    echo "File: $file"
    grep -o "-" "$file" | wc -l
done
```

### Step 6: Gene Tree Preparation

Prepare a gene tree without branch lengths for PAML analysis.

### Step 7: Null Model (M0)

Create a control file (`codeml.ctl`) with these settings:

```
seqfile = ../../Mx_aln.phy            # Path to alignment file
treefile = ../../Mx_unroot.tree       # Path to tree file
outfile = out_M0.txt                  # Output file path
   
noisy = 3                             # Screen output detail level
verbose = 1                           # Report detail level

seqtype = 1                           # Data type (1=codons)
ndata = 1                             # Number of datasets
icode = 0                             # Genetic code 
cleandata = 0                         # Remove ambiguous sites?
		
model = 0                             # Model for ω across lineages
NSsites = 0                           # Model for ω across sites
CodonFreq = 7                         # Codon frequencies
estFreq = 0                           # Estimate frequencies?
clock = 0                             # Clock model
fix_omega = 0                         # Estimate or fix omega
omega = 0.5                           # Initial or fixed omega
```

Run PAML:
```
conda activate paml 
~/.conda/envs/paml/bin/codeml file.ctl
```

Extract omega:
```
printf "omega\n" > omega_est.txt
grep 'omega ' out_M0.txt | sed 's/..*= *//' >> omega_est.txt 
```

### Step 8: Branch Model

To test if ω varies across branches, modify the control file:

```
seqfile = /path/to/HOXB1_MAFFT_Pal2Nal_one_line.phy
treefile = /path/to/tree_CS.tree
outfile = HOXB1_output_codeml_branch-site_CS.txt
noisy = 3
verbose = 1
seqtype = 1
ndata = 1
icode = 0
cleandata = 0
model = 2                             # Change to 2 for branch model
NSsites = 0
CodonFreq = 7
estFreq = 0
clock = 0
fix_omega = 0
omega = 0.5
```

### Step 9: Branch-Site Models

#### Alternative Model
Test if ω varies across both branches and sites:

```
seqfile = /path/to/HOXB1_MAFFT_Pal2Nal_one_line.phy
treefile = /path/to/tree_CS.tree
outfile = HOXB1_output_codeml_branch-site_CS.txt
noisy = 3
verbose = 1
seqtype = 1
ndata = 1
icode = 0
cleandata = 0
model = 2
NSsites = 2                           # Change to 2 for branch-site model
CodonFreq = 7
estFreq = 0
clock = 0
fix_omega = 0
omega = 0.5
```

#### Null Model
For comparison, fix ω=1:

```
seqfile = /path/to/HOXB1_MAFFT_Pal2Nal_one_line.phy
treefile = /path/to/tree_CS.tree
outfile = HOXB1_output_codeml_branch-site-null.txt
noisy = 3
verbose = 1
seqtype = 1
ndata = 1
icode = 0
cleandata = 0
model = 2
NSsites = 2
CodonFreq = 7
estFreq = 0
clock = 0
fix_omega = 1                         # Fixed to 1
omega = 1                             # Value is 1
```

### Step 10: Statistical Comparison

#### Model Comparison
Compare log-likelihood scores using the likelihood ratio test:
- **LRT statistic**: 2Δℓ = 2(ℓ1 - ℓ0)
  - ℓ0 = log-likelihood for null model
  - ℓ1 = log-likelihood for alternative model

If 2Δℓ is greater than the chi-square critical value with the appropriate degrees of freedom, the alternative model is preferred.

**Chi-Square Critical Values**: 
- df=1: 3.84 (5% significance)
- df=2: 5.99 (5% significance)

## Group B: Automated Analysis

### Script 1: Gap Count and File Selection

This script counts gaps in alignment files and selects the one with fewest gaps:

```bash
#!/bin/bash
#SBATCH -J count_GAPS
# SBATCH parameters omitted for brevity

# Default settings
TEST_MODE=0
SPECIFIC_HOX=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--test) TEST_MODE=1 ;;
        -h|--hox) 
            if [[ -n "$2" ]]; then
                SPECIFIC_HOX="$2"
                shift
            else
                echo "Error: HOX directory name must be specified"
                exit 1
            fi
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Base directory containing HOX directories
BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/03_Phylip_files"

# Destination directory
DEST_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/03_Phylip_files/01_working_dir"

# Function to count gaps in a file
count_gaps() {
    grep -o "-" "$1" | wc -l
}

# Ensure destination directory exists (only if not in test mode)
if [ $TEST_MODE -eq 0 ]; then
    mkdir -p "$DEST_DIR"
fi

# Output mode message
if [ $TEST_MODE -eq 1 ]; then
    if [ -n "$SPECIFIC_HOX" ]; then
        echo "Running in TEST MODE for HOX: $SPECIFIC_HOX"
    else
        echo "Running in TEST MODE for all HOX directories"
    fi
else
    echo "Running in EXECUTE MODE"
fi

# Determine which directories to process
if [ -n "$SPECIFIC_HOX" ]; then
    HOX_DIRS=("$BASE_DIR/$SPECIFIC_HOX")
else
    HOX_DIRS=("$BASE_DIR"/HOX*)
fi

# Loop through HOX directories
for hox_dir in "${HOX_DIRS[@]}"; do
    # Skip if not a directory
    [ -d "$hox_dir" ] || continue
    
    # Initialize variables
    min_gaps=999999
    min_gaps_file=""
    mafft_file=""
    
    # Loop through .phy files in the directory
    for file in "$hox_dir"/*.phy; do
        # Skip if no files match
        [ -e "$file" ] || continue
        
        # Count gaps
        gap_count=$(count_gaps "$file")
        
        # Check if file contains MAFFT in its name
        if [[ "$file" == *"MAFFT"* ]]; then
            mafft_file="$file"
        fi
        
        # Update if fewer gaps found
        if [ "$gap_count" -lt "$min_gaps" ]; then
            min_gaps=$gap_count
            min_gaps_file="$file"
        # If gap counts are equal and we have a MAFFT file
        elif [ "$gap_count" -eq "$min_gaps" ] && [[ "$file" == *"MAFFT"* ]]; then
            min_gaps_file="$file"
        fi
        
        # Always print file and gap count
        echo "File: $file, Gaps: $gap_count"
    done
    
    # Handle least gappy file
    if [ -n "$min_gaps_file" ]; then
        if [ $TEST_MODE -eq 1 ]; then
            echo "TEST MODE: Would copy least gappy file: $min_gaps_file to $DEST_DIR"
        else
            cp "$min_gaps_file" "$DEST_DIR/"
            echo "Copied least gappy file: $min_gaps_file to $DEST_DIR"
        fi
        
        # Additional info about selection logic
        echo "Selection logic: Least gaps = $min_gaps"
        if [[ "$min_gaps_file" == *"MAFFT"* ]]; then
            echo "Note: MAFFT file selected due to equal gap count"
        fi
    else
        echo "No .phy files found in $hox_dir"
    fi
done

echo "Processing complete."
```

### Script 2: Header Cleanup

This Python script removes HOX prefixes from sequence headers:

```python
import os
import re

input_dir = "/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/03_Phylip_files/01_working_dir"
output_dir = os.path.join(input_dir, "no_name_in_sequence")

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

def process_sequence_file(filename):
    input_path = os.path.join(input_dir, filename)
    output_path = os.path.join(output_dir, filename)

    with open(input_path, 'r') as infile, open(output_path, 'w') as outfile:
        # Read the first line (number of sequences and length) and write it exactly the same
        first_line = infile.readline().strip()
        outfile.write(first_line + "\n")

        # Process each subsequent line
        for line in infile:
            # Check if the line starts with HOX prefix
            if re.match(r'^HOX\w+_', line.strip()):
                # Split the line to remove the HOX prefix
                parts = line.strip().split()
                # Remove the HOXD4_ prefix from the first part
                new_first_part = re.sub(r'^HOX\w+_', '', parts[0])
                # Reconstruct the line with the new first part
                new_line = f"{new_first_part} {' '.join(parts[1:])}"
                outfile.write(new_line + "\n")
            else:
                # Write other lines as-is
                outfile.write(line)

    print(f"Processed {filename}")

# Process all .phy files in the input directory
processed_count = 0
for filename in os.listdir(input_dir):
    if filename.endswith('.phy'):
        process_sequence_file(filename)
        processed_count += 1

print(f"Processing complete. {processed_count} .phy files processed.")
```

### Script 3: Batch M0 Model Analysis

This script runs M0 model analysis on multiple genes:

```bash
#!/bin/bash
#SBATCH -J M0_general
# SBATCH parameters omitted for brevity

# Default settings
TEST_MODE=0
SPECIFIC_HOX=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--test) TEST_MODE=1 ;;
        -h|--hox)
            if [[ -n "$2" ]]; then
                SPECIFIC_HOX="$2"
                shift
            else
                echo "Error: HOX name must be specified"
                exit 1
            fi
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Expand the home directory path
CODEML_PATH="$(eval echo ~/.conda/envs/paml/bin/codeml)"

# Directories
WORKING_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/03_Phylip_files/01_working_dir/no_name_in_sequence"
TREE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/06_M0_model/CS_tree"
OUTPUT_BASE_DIR="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/06_M0_model/CS_tree"

# Ensure tree file exists
TREE_FILE="$TREE_DIR/tree_CS.tree"
if [ ! -f "$TREE_FILE" ]; then
    echo "Error: Tree file not found at $TREE_FILE"
    exit 1
fi

# Verify codeml path exists
if [ ! -x "$CODEML_PATH" ]; then
    echo "Error: Codeml not found at $CODEML_PATH"
    echo "Current codeml path: $CODEML_PATH"
    exit 1
fi

# Create base output directory if it doesn't exist
if [ $TEST_MODE -eq 0 ]; then
    mkdir -p "$OUTPUT_BASE_DIR"
fi

# Determine which sequence files to process
if [ -n "$SPECIFIC_HOX" ]; then
    SEQUENCE_FILES=("$WORKING_DIR"/${SPECIFIC_HOX}*.phy)
else
    SEQUENCE_FILES=("$WORKING_DIR"/*.phy)
fi

# Loop through sequence files
for seqfile in "${SEQUENCE_FILES[@]}"; do
    # Skip if no files found
    [ -e "$seqfile" ] || continue

    # Extract HOX name from filename
    hox_name=$(basename "$seqfile" | cut -d'_' -f1)

    # Create HOX-specific output directory
    hox_output_dir="$OUTPUT_BASE_DIR/$hox_name"

    if [ $TEST_MODE -eq 0 ]; then
        mkdir -p "$hox_output_dir"
    fi

    # Create codeml configuration file
    config_file="${hox_output_dir}/codeml.ctl"

    # Generate configuration file contents
    config_contents=$(cat << EOF
      seqfile = $seqfile
      treefile = $TREE_FILE
      outfile = ${hox_name}_output_codeml-M0_branch.txt
      noisy = 3
      verbose = 1
      seqtype = 1
      ndata = 1
      icode = 0
      cleandata = 0
      model = 0
      NSsites = 0
      CodonFreq = 7
      estFreq = 0
      clock = 0
      fix_omega = 0
      omega = 0.5
EOF
)

    # Test or execute mode
    if [ $TEST_MODE -eq 1 ]; then
        echo "TEST MODE: Would process file: $seqfile"
        echo "Would create directory: $hox_output_dir"
        echo "Would use codeml path: $CODEML_PATH"
        echo "Configuration file contents:"
        echo "$config_contents"
        echo "---"
    else
        # Write actual configuration file
        echo "$config_contents" > "$config_file"

        # Run codeml
        echo "Running codeml for $hox_name"
        cd "$hox_output_dir"
        "$CODEML_PATH" "$config_file"

        # Verify output files are generated
        echo "Generated files for $hox_name:"
        ls
    fi
done

echo "PAML analysis processing complete."
```

### Script 4: Results Collection

#### Script for M0 Results

This script extracts omega and log-likelihood values from M0 model results:

```bash
#!/bin/bash
#SBATCH -J Collect_omega_and_lnL
# SBATCH parameters omitted for brevity

# Directory path
parent_dir="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/06_M0_model/CS_tree"

# Output file in the parent directory
output_file="${parent_dir}/hox_analysis_results.txt"

# Write header
printf "Hox Gene\tlnL Value\tomega (dN/dS)\n" > "$output_file"

# Loop through all subdirectories in the parent directory
for dir in "$parent_dir"/*/; do
    # Extract Hox gene name from directory path
    hox_name=$(basename "$dir")
    
    # Find the output file using the new naming pattern
    out_file=$(find "$dir" -name "${hox_name}_output_codeml-M0_branch.txt")
    
    # Check if output file exists
    if [ -f "$out_file" ]; then
        # Extract lnL value - precisely extract the value after "lnL(ntime: 3 np: 8): "
        lnl=$(grep "lnL(ntime:" "$out_file" | sed -E 's/.*lnL\(ntime:[^)]*\): *(-?[0-9.]+).*/\1/')
        
        # Extract omega value
        omega=$(grep "omega (dN/dS)" "$out_file" | sed 's/..*= *//')
        
        # Write to output file
        printf "%s\t%s\t%s\n" "$hox_name" "$lnl" "$omega" >> "$output_file"
    else
        echo "Warning: Output file not found for $hox_name" >&2
    fi
done

echo "Results saved to $output_file"
```

#### Script for Branch Model Results

This script extracts log-likelihood and omega values from branch models:

```bash
#!/bin/bash
#SBATCH -J Collect_omega_and_lnL_Branches
# SBATCH parameters omitted for brevity

# Directory path
parent_dir="/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/04_Branch_model/tree_CS"

# Output files
lnl_output_file="${parent_dir}/hox_lnl_results.txt"
omega_output_file="${parent_dir}/hox_omega_results.txt"

# Write headers
printf "Hox Gene\tlnL Value\n" > "$lnl_output_file"
printf "Hox Gene\tCalSin\tTretOri\tSalMer\n" > "$omega_output_file"

# Loop through all subdirectories in the parent directory
for dir in "$parent_dir"/*/; do
    # Extract Hox gene name from directory path
    hox_name=$(basename "$dir")
    
    # Find the output file with the correct naming pattern
    out_file=$(find "$dir" -name "${hox_name}_output_codeml_branch_CS.txt")
    
    # Check if output file exists
    if [ -f "$out_file" ]; then
        # Extract lnL value - precisely extract the value after "lnL(ntime:  3  np:  9): "
        lnl=$(grep "lnL(ntime:" "$out_file" | sed -E 's/.*lnL\(ntime:[^)]*\): *(-?[0-9.]+).*/\1/')
        
        # Check if lnL is not empty
        if [ -n "$lnl" ]; then
            # Write lnL to output file
            printf "%s\t%s\n" "$hox_name" "$lnl" >> "$lnl_output_file"
        fi
        
        # Extract omega values
        omega_lines=$(awk '/w ratios as node labels:/{getline; print; getline; print}' "$out_file")
        
        # Process the extracted lines
        CalSin=$(echo "$omega_lines" | sed -n 's/.*CalSin #\([0-9.]\+\).*/\1/p')
        TretOri=$(echo "$omega_lines" | sed -n 's/.*TretOri #\([0-9.]\+\).*/\1/p')
        SalMer=$(echo "$omega_lines" | sed -n 's/.*SalMer #\([0-9.]\+\).*/\1/p')
        
        # Check if we found all omega values
        if [ -n "$CalSin" ] && [ -n "$TretOri" ] && [ -n "$SalMer" ]; then
            # Write omega values to output file
            printf "%s\t%s\t%s\t%s\n" "$hox_name" "$CalSin" "$TretOri" "$SalMer" >> "$omega_output_file"
        else
            echo "Warning: Could not extract omega values for $hox_name" >&2
        fi
    else
        echo "Warning: Output file not found for $hox_name" >&2
    fi
done

echo "lnL results saved to $lnl_output_file"
echo "Omega results saved to $omega_output_file"
```

## Directory Structure

All work is stored in: `/scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML`

Key directories include:
- `000_scripts`: Scripts and tools
- `00_Brutos`: Raw input files
- `01a_TranslatorX`: Alignments from TranslatorX
- `01b_MAFFT`: Alignments from MAFFT
- `03_Phylip_files`: Pal2Nal PHYLIP files
- `04_Branch_model`: Branch model analysis
- `05_Branch_site_model`: Branch-site model analysis
- `06_M0_model`: M0 model analysis
