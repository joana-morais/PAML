#!/bin/bash
#SBATCH -J count_GAPS
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1G
#SBATCH --time=10-00:00:00
#SBATCH --constraint=no_gpu
#SBATCH -o /scratch/joanamorais/jobs/01_OUTandERR/count_GAPS.out
#SBATCH -e /scratch/joanamorais/jobs/01_OUTandERR/count_GAPS.err


# This will count gaps, select the file with the least amount of gaos and separate them into an specific folders


# Default settings
TEST_MODE=1
SPECIFIC_HOX="HOXB1"

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