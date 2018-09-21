#!/bin/bash

#we need a fasta file that contains all scaffold sequences that we are interested in
#the scaffold title must contain a four letter species code as first charaters in the title seperated with an underscore
fasta_scaffold_file='testTIMP/TIMP.hmm.sequences.noIso.fas.scaffolds.uniq1K'
printf '' > $fasta_scaffold_file\_100Kwin

GFF_file=$1 #we need a GFF file that contains only information about our genes of interest
#we can then extract sequences around these genes.
WINDOW_SIZE='100000'


grep -P '\tgene\t' $GFF_file | while read line 

do
    ScaffoldID=$(echo $line | cut -f1 -d' ')
    SpeciesID=$(echo $ScaffoldID | cut -f1 -d'_')
    Start=$(echo $line | cut -f4 -d' ')
    End=$(echo $line | cut -f5 -d' ')

    echo $ScaffoldID $SpeciesID $Start $End $fasta_scaffold_file

    perl 01_get_scaffold_window.pl $fasta_scaffold_file $ScaffoldID $Start $End $WINDOW_SIZE >> $fasta_scaffold_file\_100Kwin

    sleep 1 

done 