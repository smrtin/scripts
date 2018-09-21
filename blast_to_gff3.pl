#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;

#usage: perl blast_to_gff3.pl [options] [file ...]

my $threshold = 1e-3;

GetOptions('t|threshold:s' => \$threshold);

my $count =0;
while(<>) {
    next if /^\#/;
    my @column = split;
    next if $column[10] > $threshold;
    
    my ($start,$end) = sort { $a <=> $b } ($column[8],$column[9]);
    
    print join("\t", $column[1],'BLAST','match',
	       $start,$end,$column[2],$column[8] < $column[9] ? '+' : '-',
	       '.',
	       sprintf("ID=match%d;Name=%s;Target=%s+%d+%d",
		       $count++,$column[0],$column[0],$column[6],$column[7])),"\n";
}
    
