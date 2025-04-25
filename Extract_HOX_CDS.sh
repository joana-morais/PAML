################################################################################################
# Extract HOX genes from annotations                                                           #    
# Joana Morais                                                                                 #
# Based on: https://github.com/abacus-gene/paml-tutorial/tree/main/positive-selection/00_data  #
# 20.03.2025                                                                                   #
################################################################################################


# Extract Hox genes with CDS, so it is possible to see the reading frame => this is important to read the sequences correctly

grep -i -A 4 "[^a-z]hox" Calyptommatus_sinebrachiatus.EVM.SWISSPROT_modified.gff > hox_genes_with_cds.gff3

# There will be some spaces in the sequence, remove them:

awk -F'\t' 'NF==1' your_file.gff3

awk -F'\t' 'NF==1 {print NR, $0}' your_file.gff3

awk -F'\t' 'NF==9 || /^#/' your_file.gff3 > fixed_file.gff3

----------------------------/----------------------------/----------------------------

# Extract CDS and DNA

#!/bin/bash
#SBATCH -J hox_sequences_extracted_CS
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=2G
#SBATCH --time=3:00:00
#SBATCH --constraint=no_gpu
#SBATCH --output=/scratch/joanamorais/jobs/01_OUTandERR/hox_sequences_extracted_CS.%j.out
#SBATCH --error=/scratch/joanamorais/jobs/01_OUTandERR/hox_sequences_extracted_CS.%j.err



GFF_FILE="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/02.hox_genes_with_cds_AGAT.gff3"
FASTA_FILE="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/GCA_022412395.1_HLcalSin1_simple_header.fasta"
AGAT_IMAGE="/scratch/joanamorais/images/agat_1.4.2--pl5321hdfd78af_0.sif"
OUTPUT="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/hox_sequences_extracted_PROTEIN_CS.fasta"

module load apptainer


apptainer exec -B /scratch/joanamorais/ \
-B /scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX \
"$AGAT_IMAGE" agat_sp_extract_sequences.pl \
-g "$GFF_FILE" \
-f "$FASTA_FILE" \
-p \
-t 'CDS' \
-o "$OUTPUT


# Extract CDS and DNA

#!/bin/bash
#SBATCH -J hox_sequences_extracted_CS
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=joanamorais@zedat.fu-berlin.de
#SBATCH --partition=begendiv,main
#SBATCH --qos=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=2G
#SBATCH --time=3:00:00
#SBATCH --constraint=no_gpu
#SBATCH --output=/scratch/joanamorais/jobs/01_OUTandERR/hox_sequences_extracted_CS.%j.out
#SBATCH --error=/scratch/joanamorais/jobs/01_OUTandERR/hox_sequences_extracted_CS.%j.err



GFF_FILE="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/02.hox_genes_with_cds_AGAT.gff3"
FASTA_FILE="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/GCA_022412395.1_HLcalSin1_simple_header.fasta"
AGAT_IMAGE="/scratch/joanamorais/images/agat_1.4.2--pl5321hdfd78af_0.sif"
OUTPUT="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/hox_sequences_extracted_DNA_CS.fasta"

module load apptainer


apptainer exec -B /scratch/joanamorais/ \
-B /scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX \
"$AGAT_IMAGE" agat_sp_extract_sequences.pl \
-g "$GFF_FILE" \
-f "$FASTA_FILE" \
-t 'gene' \
-o "$OUTPUT"


#The output will not be named. You need now to assing the names to the sequences:



awk -F'\t' '$3 == "gene" {match($9, /ID=([^;]+)/, id); match($9, /Name=([^;]+)/, name); if (id[1] && name[1]) print id[1], name[1]}' your_file.gff3 > gene_map.txt

awk 'NR==FNR {map[$1]=$2; next} /^>/ {match($0, /gene=([^ ]+)/, g); if (g[1] in map) sub(g[1], map[g[1]]); print; next} {print}' gene_map.txt your_fasta_file.fasta > renamed.fasta

awk '/^>/ {match($0, /gene=([^ ]+)/, g); sub(/gene=[^ ]+ /, "", $0); print ">" g[1] " " substr($0, 2); next} {print}' input.fasta > reordered.fasta



#Will difer in the type of data



# Step 1: Your gene.txt is already in the right format (ID Name), so we can use it directly as gene_map.txt
awk -F'\t' '$3 == "gene" {match($9, /ID=([^;]+)/, id); match($9, /Name=([^;]+)/, name); if (id[1] && name[1]) print id[1], name[1]}' your_file.gff3 > gene_map.txt


# Step 2: Rename genes in the FASTA file
awk 'NR==FNR {map[$1]=$2; next} /^>/ {match($0, /evm.TU.[^ ]+/, g); 
    if (g[0] in map) sub(g[0], map[g[0]]); print; next} {print}' gene.txt fasta_file.fasta > renamed.fasta

# Step 3: Reorder the FASTA headers if needed
awk '/^>/ {match($0, /^>([^ ]+)/, g); 
    rest = substr($0, length(g[0])+1);
    print ">" g[1] rest; next} {print}' renamed.fasta > reordered.fasta


#######################

# Step 1: Your gene.txt is already in the right format (ID Name)

# Step 2: Rename genes in the FASTA file - looks for gene=ID and replaces with gene=Name
awk 'NR==FNR {map[$1]=$2; next} 
    /^>/ {
        line=$0;
        match($0, /gene=([^ ]+)/, g);
        if (g[1] in map) {
            gsub("gene=" g[1], "gene=" map[g[1]], line);
        }
        print line;
        next;
    } 
    {print}' gene.txt your_fasta_file.fasta > renamed.fasta

# Step 3: Reorder the FASTA headers to have gene name at the beginning
awk '/^>/ {
        match($0, /gene=([^ ]+)/, g);
        if (g[1]) {
            rest = $0;
            gsub(/^>[^ ]+ gene=[^ ]+ /, "", rest);
            print ">" g[1] " " rest;
        } else {
            print $0;
        }
        next;
    }
    {print}' renamed.fasta > reordered.fasta
