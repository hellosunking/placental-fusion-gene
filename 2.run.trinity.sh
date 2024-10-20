#!/bin/bash
#
# Author: Kun Sun @ SZBL (sunkun@szbl.ac.cn)
# Date  :
#
set -o nounset
set -o errexit
#command || { echo "command failed"; exit 1; }

if [ $# -lt 4 ]
then
	echo
	echo "Usage: $0 <supporting.read1.fq> <supporting.read2.fq> </path/to/trinity> <out.Trinity.dir>"
	echo "You may need to concatenate the supporting reads for each fusion gene from different samples first."
	echo "Trinity requires the output.dir to contain the word 'trinity', so I will add it if necessary."
	echo
	exit 2
fi > /dev/stderr

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`/bin

Trinity=$3

if [[ $4 =~ trinity ]]
then
	outDir=$4
else
	outDir=$4.trinity
	echo "INFO: the output directory is set to '$outDir'."
fi

## run Trinity
$Trinity --seqType fq --output $outDir --max_memory 1G --CPU 4 --no_version_check --left $1 --right $2

## if there is more than 1 assemblies in Trinity, use the one with most supporting reads via blat
cnt=`grep "^>" $outDir/Trinity.fasta  | wc -l` 
if [ $cnt -gt 1 ]
then
	perl $PRG/fq2fa.pl $1 >$outDir/supporting.read1.fa
	perl $PRG/fq2fa.pl $2 >$outDir/supporting.read2.fa
	$PRG/blat $outDir/Trinity.fasta $outDir/supporting.read1.fa $outDir/blat.read1.to.trinity
	$PRG/blat $outDir/Trinity.fasta $outDir/supporting.read2.fa $outDir/blat.read2.to.trinity
	perl $PRG/determine.best.Trinity.assembly.pl $outDir/blat.read1.to.trinity $outDir/blat.read2.to.trinity $outDir/Trinity.fasta >$outDir/fusion.assembly.fa
else
	ln -s Trinity.fasta $outDir/fusion.assembly.fa
fi

