#!/bin/bash
#SBATCH -J Collect_omega_and_lnL
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1G
#SBATCH --time=10-00:00:00
#SBATCH --constraint=no_gpu
#SBATCH -o /scratch/joanamorais/jobs/01_OUTandERR/Collect_omega_and_lnL.out
#SBATCH -e /scratch/joanamorais/jobs/01_OUTandERR/Collect_omega_and_lnL.err

##Change the name/folder of the model!


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
