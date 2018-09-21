#!/bin/bash


PROTEIN_FOLDER='../Proteins/modifiedTitles'
#in this folder the Proteinfiles must have a four letter species code as first characters of their filename
#the sequence header must also contain the four letter species code as first characters seperated with an underscore
#the proteinsequence must be joined in one line resulting in one line with the header followed by one line of proteinsequence...

OUTPUT_FOLDER='../Results/' 
#relative or absolute path to the folder where results are collected

#we need a Folder ./HMMs where Hidden Markov Models are stored, characterizing a conserved domain
#in the file Peptidases.txt we can specify the conserved protein domains we want to look for


for HMM in $( ls ./HMMs/| grep -f Peptidases.txt ) 
do
  #initialize outputfile
  printf '' > $OUTPUT_FOLDER/$HMM.sequences

  echo looking for $HMM

  for PROTEINS in $( ls $PROTEIN_FOLDER )
  do
    for SPECIES in $(cat /home/smartin/DATA/Species_list.txt ) # in the file Species_list.txt we have a list of four letter species code that we want to include in our data set
    do
      SPEC=$(echo $PROTEINS | cut -f1 -d'_')
      
	if [ $SPEC == $SPECIES ]; then
	  echo "$PROTEINS and $SPECIES and $SPEC"
     

	  hmmsearch -E 1e-20 --domE 1e-20 -o hmmsearch.output --tblout $HMM.$PROTEINS.output ./HMMs/$HMM $PROTEIN_FOLDER/$PROTEINS

	  AHIT=$( grep -v '#' $HMM.$PROTEINS.output |cut -d' ' -f1 )

	  if [[ $AHIT ]] ; then
	    for MYHIT in $( grep -v '#' $HMM.$PROTEINS.output |cut -d' ' -f1 )
	      do 
	      grep -A 1 "$MYHIT" $PROTEIN_FOLDER/$PROTEINS >> $OUTPUT_FOLDER/$HMM.sequences
	      done

	  fi
    
  
	  rm $HMM.$PROTEINS.output
	fi
    done
    
    
  done
  #check for isoforms...
  
bash CheckAndFilterIsoforms.bash $OUTPUT_FOLDER/$HMM.sequences
done
