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
	echo "Usage: $0 <supporting.read1.fq> <supporting.read2.fq> </path/to/genome.fa> <trinity.out.dir>"
	echo "You may need to manually check the results using IGV or UCSC genome browser."
	echo
	exit 2
fi > /dev/stderr

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`/bin

## re-map the reads and assembly to human genome using blat
$PRG/blat $3 $4/fusion.assembly.fa $4/blat.fusion.assembly.to.genome.psl &

perl $PRG/fq2fa.pl $1 >$4/supporting.read1.fa
perl $PRG/fq2fa.pl $2 >$4/supporting.read2.fa
$PRG/blat $3 $4/supporting.read1.fa $4/read1.to.genome.psl &
$PRG/blat $3 $4/supporting.read2.fa $4/read2.to.genome.psl &

wait
$PRG/pslToBed $4/blat.fusion.assembly.to.genome.psl $4/blat.fusion.assembly.to.genome.bed
$PRG/pslToBed $4/read1.to.genome.psl $4/blat.read1.to.genome.bed
$PRG/pslToBed $4/read2.to.genome.psl $4/blat.read2.to.genome.bed

## align the supporting reads to the assembly using bwa
mkdir -p $4/bwa.index
bwa index -p $4/bwa.index/bwa $4/fusion.assembly.fa 2>/dev/null
bwa mem -T 0 $4/bwa.index/bwa $1 $2 | samtools view -b - | samtools sort -o $4/bwa2fusion.bam -
samtools index -@ 4 $4/bwa2fusion.bam

