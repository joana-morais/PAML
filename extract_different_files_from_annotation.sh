##########################################################
# Agat Tools: extract different files from annotation     #  
# Joana Morais                                           #
# 20.03.2025                                             #
##########################################################


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

# gene

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





###############

# CDS

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
-o "$OUTPUT"

###############

# PROTEIN

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



GFF_FILE="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/02.hox_genes_with_cds_fixed.AGAT.gff3"
FASTA_FILE="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/GCA_022412395.1_HLcalSin1_simple_header.fasta"
AGAT_IMAGE="/scratch/joanamorais/images/agat_1.4.2--pl5321hdfd78af_0.sif"
OUTPUT="/scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX/CDS_hox_sequences_extracted_DNA_CS.fasta"

module load apptainer


apptainer exec -B /scratch/joanamorais/ \
-B /scratch/joanamorais/jobs/02_Annotation/02.annotation.consensus/EVM/SWISS_EVM/07.HOX \
"$AGAT_IMAGE" agat_sp_extract_sequences.pl \
-g "$GFF_FILE" \
-f "$FASTA_FILE" \
-t 'p' \
-o "$OUTPUT"



# Check: https://agat.readthedocs.io/en/latest/tools/agat_sp_extract_sequences.html
