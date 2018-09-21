#!/bin/bash

#to use this script we need
GENETREE=$1 #'M10_GeneTree.treefile'
SPECIESTREE=$2 #'BUSCO_SpeciesTree.treefile.nwk'

#collapse all nodes with a bootstrap support below 80
java -jar TreeCollapseCL4.jar -f $GENETREE -b 80

newGeneTree=$(echo $GENETREE | sed -r 's/\./_80coll\./')

##in some cases the branch length must be removed... this causes problems for some reason...
#find the best root of the species tree...
sed -r 's/:[0-9].[0-9]+//g' $newGeneTree > $newGeneTree.no_branchlength
#threshold
i=95

echo $i
#find best root of genetree
java -jar Notung-2.9.jar $newGeneTree.no_branchlength -s $SPECIESTREE --root --speciestag prefix --treeoutput newick --exact-losses --costdup 2 --costloss 1.5 | echo tree was rooted #costs influence number of clusters that come out... if costdup > costloss => more clusters
echo

#rearrange weak nodes...
java -jar Notung-2.9.jar $newGeneTree.no_branchlength.rooting.0 -s $SPECIESTREE --rearrange --threshold $i --speciestag prefix --treeoutput nhx --nolosses --homologtabletabs --costdup 2 --costloss 1.5 | grep 'Event Score is' | cut -f2 -d','


#mark duplication events in tree
cat $newGeneTree.no_branchlength.rooting.0.rearrange.0 | sed -r 's/\]/\]\n/g' | sed -r 's/\[&&NHX:.+D=Y.*\]/DUP/g' | sed -r 's/\[&&NHX:.+\]//g' | sed -r 's/n[0-9]+|r[0-9]+//g' | sed -r 's/(:[0-9]+\.[0-9]+)DUP/DUP\1/' | tr -d "\n" > $newGeneTree.no_branchlength.rooting.0.rearrange.0.duplications
#transform to cladogram
cat $newGeneTree.no_branchlength.rooting.0 | sed -r 's/\]/\]\n/g' | sed -r 's/\[&&NHX:.+D=Y.*\]//g' | sed -r 's/\[&&NHX:.+\]//g' | sed -r 's/n[0-9]+|r[0-9]+//g' | sed -r 's/E-[0-9]+//g' |sed -r 's/:[0-9]+\.[0-9]+//g' | tr -d "\n" > $newGeneTree.no_branchlength.rooting.0.clado
#transform to cladogram
cat $newGeneTree.no_branchlength.rooting.0.rearrange.0 | sed -r 's/\]/\]\n/g' | sed -r 's/\[&&NHX:.+D=Y.*\]//g' | sed -r 's/\[&&NHX:.+\]//g' | sed -r 's/n[0-9]+|r[0-9]+//g' |  sed -r 's/E-[0-9]+//g'| sed -r 's/:[0-9]+\.[0-9]+//g'| tr -d "\n" > $newGeneTree.no_branchlength.rooting.0.rearrange.0.clado


#trimm of the first lines...
tail -n +14 $newGeneTree.no_branchlength.rooting.0.rearrange.0.homologs.txt > $newGeneTree.no_branchlength.rooting.0.rearrange.0.trimmed_homologs.txt

#make absent present matrix....
perl 01_orthoPara_Notung.pl $newGeneTree.no_branchlength.rooting.0.rearrange.0.trimmed_homologs.txt