#!/usr/bin/perl
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :

use strict;
use warnings;

if( $#ARGV < 0 ) {
	print STDERR "\nUsage: $0 <in.fq>\n\n";
	exit 2;
}

open IN, "$ARGV[0]" or die( "$!" );
while( my $sid = <IN> ) {
	my $seq = <IN>;
	<IN>;
	<IN>;

	$sid =~ s/^@/>/;
	$sid =~ s/\//.r/;
	print $sid, $seq;
}
close IN;


