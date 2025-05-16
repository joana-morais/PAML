# PAML
PAML Easy Guide


Here I will give step by step what needs to be done from a sequence of DNA to dN/dS analysis using PAML. 

Before starting:
		I used annotated genomes (done by me). I will only pursue this analysis with HOX genes. How to annotate genomes will be done in a separeted repository. 
		All scripts were done in a cluster (CURTA:Freie Universität Berlin)
		I use a lot (A LOT) agat (https://github.com/NBISweden/AGAT)

1. Extract HOX genes from your assembles =>  Extract_HOX_CDS.sh
	a) You can extract any type of sequence (see agat tools repository)

2. Remove HOX that are not present in every single species => remove_HOX.sh // presence_absence_gene_matrix.sh

3. Separate genes in folders (split_fasta.py and fasta_gene_organizer.py)

4. Make them into one line (one_line_fasta.pl and bash_one_line_fasta.sh)

5. The sequences should look like 00_data/CS

Aligment:

1. Usage of Pal2Nal (pal2nal.sh and Aligment_pal2nal.py)

2. TranslatorX Clustal W: All aligments were done with the -p C for clustalW )done via perl /scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/000_scripts/translatorX.pl
(translatorX.sh / TranslatorX_clustalw.sh)