#!/bin/perl
use strict;
use warnings;


my $Infile=$ARGV[0];
open(IN, '<',"$Infile") || die "Can't open $Infile -- fatal\n";

my $Outfile="$Infile".'.intermediate';
open(OUT, '>',"$Outfile") || die "Can't open $Outfile -- fatal\n";

my $Outfile2="$Infile".'.absPres';
open(OUT2, '>',"$Outfile2") || die "Can't open $Outfile2 -- fatal\n";

my $Outfile3="$Infile".'.Clusters';
open(OUT3, '>',"$Outfile3") || die "Can't open $Outfile3 -- fatal\n";


my $first=1;

my @SequenceTitles;
my $species;

while (my $line = <IN>){

	chomp $line;
	my @split_line = split(/\t/,$line);
	my $counter = 0;
	$species = shift(@split_line);

	if($first){
		#print OUT "the first line\n";
		$first = 0;
		@SequenceTitles = @split_line;
	}	
	
	 else{
	 print OUT "$species\t";
	 for(@split_line){
	 
	 if($_=~m/O/){
	 print OUT "$SequenceTitles[$counter]\t";}
	 $counter++;
	 
	 }
	 print OUT "\n";
	 }
}

my @hits;

for(@SequenceTitles){
	my $Cluster = `grep "$_" $Outfile`;

	my $hit = join ("\t", uniq( sort (split(/\s/,$Cluster))));
	push (@hits, $hit);
}

my @uniqHits=uniq(@hits);
my $ClusterNumber=1;

for(@uniqHits){
	my $cluster=join('|', split("\t", $_ ));
	print OUT3 "Cluster:$ClusterNumber\t$cluster\n";$ClusterNumber++;
}

my @ALLspecies= split("\n", `cat /home/smartin/DATA/PubSpecies_final2.txt`);

for my $spec (@ALLspecies){
	chomp $spec;
	print OUT2 "$spec";

	for (@uniqHits){
		#print "$_\n";
		if($_=~m/.*$spec.*/){
			my @number = $_=~m/$spec\_/g;
			my $count = scalar @number;
			print OUT2 "\t$count";
		}
		else{print OUT2 "\t0";}
	}

	print OUT2 "\n";
}


################################
sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}