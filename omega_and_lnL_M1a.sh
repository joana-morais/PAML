#!/bin/bash
#SBATCH -J Collect_omega_and_lnL_Branches
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1G
#SBATCH --time=10-00:00:00
#SBATCH --constraint=no_gpu
#SBATCH -o /scratch/joanamorais/jobs/01_OUTandERR/Collect_omega_and_lnL_Branches.out
#SBATCH -e /scratch/joanamorais/jobs/01_OUTandERR/Collect_omega_and_lnL_Branches.err

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
