#!/bin/bash

#usage: bash CheckAndFilterIsoforms.bash ProteinSeq.fasta

#
#what we need before running this script:
#- for each species we need a fasta file with predicted proteinsequence in a folder (e.g. ../Proteins/modifiedTitles/)
#- the file name must begin with a four letter species identifier
#- the protein sequence must be in one line
#- a gff-file starting with a species identifier in the titles (../GFFs/keep/)

#we need proteinsequence file of our genes of interest with a four letter species identifier as first elements of the sequence header seperated with an underscore
SEQFILE=$1

printf '' > $SEQFILE.ISOcheck #initiate file...
printf '' > $SEQFILE.noIso.fas #initiate file...


#################################
#	check for isoforms	#
#################################
NUMBEROFSEQUENCES=$(grep -c '>' $SEQFILE)
echo
echo checking for Isoforms in $SEQFILE
echo File contains $NUMBEROFSEQUENCES sequences...
echo 

for SEQUENCE in $( grep '>' $SEQFILE ) #get all the sequence titles
do 
SPECIES=$( echo $SEQUENCE | sed 's/>\(\w\w\w\w\)_\(.*\)/\1 \2/' | cut -d' ' -f1 ) #get the species identifier
SEQID=$( echo $SEQUENCE | sed 's/>\(\w\w\w\w\)_\(.*\)/\1 \2/' | cut -d' ' -f2 ) #get the sequence identifier from the original dataset

THEGREP=$(zgrep "protein_id=$SEQID" ../GFFs/keep/$SPECIES*) #go for protein_id= this should be present in all gff files

if [[ $THEGREP ]] ; then #if the grep was successfull...

#echo we have a hit
PARENT=$(echo $THEGREP | tr ";" "\n" | grep 'Parent=' | sort | uniq | sed 's/Parent=//' ) #identify the parent ID (the RNA-ID) of the CDS that the protein_id
GENEID=$(zgrep "ID=$PARENT;" ../GFFs/keep/$SPECIES* | tr ";" "\n" | grep 'Parent=' | sort | uniq | sed 's/Parent=//') #do another grep and identify the Gene ID
PROTEINLENGTH=$( cat ../Proteins/modifiedTitles/$SPECIES_* | grep  -A 1 "$SEQUENCE"  | grep -v '>' | wc -m ) #get the sequence out of the twoliner sequencefile and count characters...
echo $SEQUENCE $SPECIES $SEQID $PARENT $GENEID $PROTEINLENGTH >> $SEQFILE.ISOcheck

 else #if the first grep was not successfull we are probably working with GBR data...
  PARENT=$(zgrep "$SEQID" ../GFFs/keep/$SPECIES*  | grep -P '\tmRNA\t'| tr ";" "\n" | cut -f9 |  tr ";" "\n" | grep 'ID=' | sed 's/ID=//')
  GENEID=$(zgrep "$SEQID" ../GFFs/keep/$SPECIES*  | grep -P '\tmRNA\t'| tr ";" "\n" | grep 'Parent=' | sed 's/Parent=//')
  PROTEINLENGTH=$( cat ../Proteins/modifiedTitles/$SPECIES_* | grep  -A 1 "$SEQUENCE"  | grep -v '>' | wc -m ) #get the sequence out of the twoliner sequencefile and count characters...
  echo $SEQUENCE $SPECIES $SEQID $PARENT $GENEID $PROTEINLENGTH >> $SEQFILE.ISOcheck
fi

done

#########################################################################
#   catch the sequences without doubles and if doubles take the longest 	#
#########################################################################

echo kick out smaller isoforms!
for SPECIES in $(grep '>' $SEQFILE |sed 's/>\(\w\w\w\w\)_\(.*\)/\1 \2/' | cut -d' ' -f1 | sort | uniq ) #get a list of speciesIDs that are present in our sequence file...
do 
    LISTofDOUBLES=$(grep " $SPECIES " $SEQFILE.ISOcheck | cut -d' ' -f5 | sort | uniq -d) #check if we can find doubles in the geneID #need to have space before and after specID to be more accurate!!!

        if [[ $LISTofDOUBLES ]]; then
        #echo we have doubles
            for GENE in $(grep " $SPECIES " $SEQFILE.ISOcheck | cut -d' ' -f5 | sort | uniq) #get all the geneIDs doubles and singles...
            do 
                grep " $SPECIES " $SEQFILE.ISOcheck | grep " $GENE " | sort -k 6 -g -r | head -1 | cut -d' ' -f1 | xargs -I % grep -A 1 '%' $SEQFILE >> $SEQFILE.noIso.fas #sort by the protein length number and get the longest ... extract seqID and then get sequence... use space in grep to make gene name more specific!!!
       
            done

        else
            grep " $SPECIES " $SEQFILE.ISOcheck | cut -d' ' -f1 | xargs -I % grep -A 1 '%' $SEQFILE >> $SEQFILE.noIso.fas # if there are no doubles just get the seqID and the sequence....
        fi

done

#################################
#	align the sequences 	#
#################################
#echo start alignment with mafft
# echo align $SEQFILE ...
#mafft --localpair --maxiterate 1000 --quiet --reorder --thread 6 $SEQFILE.noIso.fas > $SEQFILE.noIso.linsi.fas

#########################################
#	build a tree with fasttree	#
#########################################
#echo start tree calculation with fasttree

#fasttree -quiet $SEQFILE.noIso_aligned.fas > $SEQFILE.noIso_aligned.nwk
#fasttree -quiet -nosupport $SEQFILE.noIso_aligned.fas > $SEQFILE.noIso_aligned_noSup.nwk
