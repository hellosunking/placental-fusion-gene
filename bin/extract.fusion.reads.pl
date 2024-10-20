#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :

use strict;
use warnings;

if( $#ARGV < 3 ) {
	print STDERR "\nUsage: $0 <in.tsv> <read1.fq[.gz]> <read2.fq[.gz]> <out.dir>\n\n";
	exit 2;
}

if( $ARGV[1] eq $ARGV[2] ) {
	print STDERR "ERROR: read1 is the same as read2!\n";
	exit 1;
}

unless( -d $ARGV[3] ) {
	print STDERR "WARNING: output dir $ARGV[3] does not exist! I will make one.\n";
	if( system( "mkdir -p $ARGV[3]" ) ) {
		print STDERR "ERROR: mkdir failed!\n";
		exit 1;
	}
}

my %fusion;
open IN, "$ARGV[0]" or die( "$!" );
while( <IN> ) {
	chomp;
	my @l = split /\t/;
	foreach my $r (split /,/, "$l[10],$l[11]") {
		$r =~ s/^([ES]RR\d+)\.sra/$1/;	## to be compatiable with newer versions of fasterq-dump
		$fusion{$r}->{$l[0]} = 1;
		## in case that 1 read exists in > 1 fusion genes
	}
}
close IN;

if( $ARGV[1]=~/\.gz$/ ) {
	open R1, "zcat $ARGV[1] |" or die( "$!" );
} else {
	open R1, "$ARGV[1]" or die( "$!" );
}

if( $ARGV[2]=~/\.gz$/ ) {
	open R2, "zcat $ARGV[2] |" or die( "$!" );
} else {
	open R2, "$ARGV[2]" or die( "$!" );
}

my $cnt = 0;
my (%read1, %read2);
while( my $rid = <R1> ) {
	my $seq1 = <R1>;
	<R1>;
	my $qual1 = <R1>;

	<R2>;
	my $seq2 = <R2>;
	<R2>;
	my $qual2 = <R2>;

	chomp( $rid );
##	$rid =~ s/\/.*//;	## @V350015402L1C005R0140012359/1 style
	if( $rid =~ /^@(\S+)/ ) {
		$rid = $1;
		$rid =~ s/\/.*//;
		$rid =~ s/^([ES]RR\d+)\.sra/$1/;
		if( exists $fusion{$rid} ) {
#			print STDERR "Met $rid";
			foreach my $g ( keys %{$fusion{$rid}} ) {
				## note that the /1 and /2 are required by trinity
				$read1{$g} .= "\@$rid/1\n$seq1+\n$qual1";
				$read2{$g} .= "\@$rid/2\n$seq2+\n$qual2";
			}
		}
	}

	$cnt ++;
#	unless( $cnt & 0xfffff ) {	## report every 1M reads
#		print STDERR "\r$cnt reads loaded";
#	}
}
close R1;
close R2;
print STDERR "\r\nDone: $cnt reads loaded in total.\n";

foreach my $g ( keys %read1 ) {
	open R1, ">$ARGV[3]/$g.read1.fq" or die( "$!" );
	open R2, ">$ARGV[3]/$g.read2.fq" or die( "$!" );

	print R1 $read1{$g};
	print R2 $read2{$g};

	close R1;
	close R2;
}

