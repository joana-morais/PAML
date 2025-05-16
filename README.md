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

1. Usage of Pal2Nal: Pal2Nal uses a protein alignment (done in step 1) and a file with the DNA sequence to match (file we already had), and then outputs a codon-based DNA alignment => (pal2nal.sh and Aligment_pal2nal.py) // how to use it: pal2nal.pl data1_prot_mafft_aln.fasta data1_nuc_mafft_aln.fasta -output fasta > pal2nal_checks/data1_pal2nal_mafft_out.fasta


2. TranslatorX Clustal W: All aligments were done with the -p C for clustalW )done via perl /scratch/joanamorais/jobs/03_Hox/analysis/HOX/Selection_analysis/PAML/000_scripts/translatorX.pl
(translatorX.sh / TranslatorX_clustalw.sh)

3. MAFFT via TranslatorX (./translatorX.pl -i data1_unaln.fasta -p F -o mafft_translatorx )

4.  Convert output file to one line fasta file HOX_FASTAtoPHYL.sh (this is important for PAML) => perl one_line_fasta.pl data1pal2nal_out.fasta 

5. convert the FASTA file in PHYLIP format (this is important for PAML) => FASTAtoPHYL.pl // fasta_to_oneline_to_phylip.pl

6. You will have to chose the one with lesser gaps => count_gaps.sh

7. Gene tree => create a gene tree (You need to get rid of branch lengths (not a problem for me since I have a trees without branch lengths))

8. Run the models 

9. Get omega and lnL results from directories (different models) => omega_and_lnL_MX