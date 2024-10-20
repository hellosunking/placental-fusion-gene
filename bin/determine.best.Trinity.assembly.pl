#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# First version:
# Modified date:

use strict;
use warnings;

if( $#ARGV < 2 ) {
	print STDERR "\nUsage: $0 <read1.psl> <read2.psl> <trinity.fa>\n\n";
	exit 2;
}

## extract highest scores for each read
my (%s1, %s2);
open IN, "$ARGV[0]" or die( "$!" );
<IN>;<IN>;<IN>;<IN>;<IN>;	## 5-line headers
while( <IN> ) {
	chomp;
	my @l = split /\t/;	##score whatever x 8 read.id whatever
	unless( exists $s1{$l[9]} && $s1{$l[9]} > $l[0] ){
		$s1{$l[9]} = $l[0];
	}
}
close IN;

open IN, "$ARGV[01]" or die( "$!" );
<IN>;<IN>;<IN>;<IN>;<IN>;	## 5-line headers
while( <IN> ) {
	chomp;
	my @l = split /\t/;	##score whatever x 8 read.id whatever
	unless( exists $s2{$l[9]} && $s2{$l[9]} > $l[0] ){
		$s2{$l[9]} = $l[0];
	}
}
close IN;

## checking the assemblies with best scores
my %hit;
open IN, "$ARGV[0]" or die( "$!" );
<IN>;<IN>;<IN>;<IN>;<IN>;   ## 5-line headers
while( <IN> ) {
	chomp;
	my @l = split /\t/; ##score whatever x 8 read.id whatever x 3 assembly.id
	if( $l[0] == $s1{$l[9]} ) {
		$hit{$l[13]}->{$l[9]} = 1;
	}
}
close IN;

open IN, "$ARGV[1]" or die( "$!" );
<IN>;<IN>;<IN>;<IN>;<IN>;   ## 5-line headers
while( <IN> ) {
	chomp;
	my @l = split /\t/; ##score whatever x 8 read.id whatever x 3 assembly.id
	if( $l[0] == $s2{$l[9]} ) {
		$hit{$l[13]}->{$l[9]} = 1;
	}
}
close IN;

my $bestScore = 0;
foreach my $assembly ( keys %hit ) {
	my @here = keys %{$hit{$assembly}};
	$bestScore = $#here if $#here > $bestScore;
#	print STDERR "score $assembly = $#here\n";
}

my @candidate;
foreach my $assembly ( keys %hit ) {
	my @here = keys %{$hit{$assembly}};
	push @candidate, $assembly if $#here == $bestScore;
}

## extract fasta
my %fasta;
open IN, "$ARGV[2]" or die( "$!" );
my $id = '';
while( <IN> ) {
	if( /^>(\S+)/ ) {
		$id = $1;
	} else {
		chomp;
		$fasta{$id} .= $_;
	}
}
close IN;

my $bestID;
if( $#candidate == 0 ) {	## only 1 best hit
	$bestID = $candidate[0];
#	print STDERR "Only 1 best hit: $bestID\n";
} else {	## output the longest one
	my @sorted = sort { length($fasta{$b}) <=> length($fasta{$a}) } @candidate;
	$bestID = $sorted[0];
#	print STDERR "Choose longest: $bestID\n";
}
print ">$bestID\n$fasta{$bestID}\n";

