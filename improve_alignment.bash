#!/bin/bash

#take a sequence file, align protein sequences using MAFFT, 
#identify outliers (sequences that are not well aligned) and exclude them using OD-Seq 
#run 5 rounds and in the end form a core alignment to which the outliers are added using MAFFT --add

SEQFILE=$1

cp $SEQFILE $SEQFILE.work

for i in `seq 1 5`;
do 

SeqNumber=$(grep -c '>' $SEQFILE.work);

echo round $i
echo alignment of $SeqNumber sequences ...

mafft --reorder --localpair --maxiterate 1000 --thread 6 --quiet $SEQFILE.work > $SEQFILE.work.ali #--quiet


/home/smartin/OD-Seq/OD-seq --input $SEQFILE.work.ali --outlier $SEQFILE.work.outlier$i.fas --core $SEQFILE.work.core$i.fas

cp  $SEQFILE.work.core$i.fas $SEQFILE.work
done


mafft --reorder --localpair --maxiterate 1000 --thread 6  $SEQFILE.work > $SEQFILE.work.ali #--quiet

cat $SEQFILE.work.outlier* > $SEQFILE.OUTLIERS

mafft --reorder --thread 6 --localpair --maxiterate 1000 --keeplength --add $SEQFILE.OUTLIERS $SEQFILE.work.ali > $SEQFILE.final
