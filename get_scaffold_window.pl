#!/bin/perl

use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Bio::DB::Fasta;


my $file_fasta = $ARGV[0];
my $db = Bio::DB::Fasta->new($file_fasta); #create a fasta DB


my $scaffold_id = $ARGV[1];
my $windowsize = $ARGV[4];

my $gene_start = $ARGV[2] - $windowsize ;
if ($gene_start <= 0 ){ 
    $gene_start = 1 ;
    }

my $length   = $db->length($scaffold_id);
my $gene_end = $ARGV[3] + $windowsize ;
if ($gene_end >= $length ) {
    $gene_end = $length;
    }

my $gene_seq = $db->seq($scaffold_id, $gene_start, $gene_end ); #extract sequence region

print ">$scaffold_id\n$gene_seq\n";