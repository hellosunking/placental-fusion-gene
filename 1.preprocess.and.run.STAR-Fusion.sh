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
	echo "Usage: $0 <read1.fq[.gz]> <read2.fq[.gz]> <output.prefix> <STAR-Fusion.dir> [platform=illumina]"
	echo "Note: You need to download the 'GRCh38_gencode_v37_CTAT_lib_Mar012021' annotation and put it to STAR-Fusion's directory."
	echo
	exit 2
fi > /dev/stderr

currSHELL=`readlink -f $0`
PRG=`dirname $currSHELL`/bin

sid=$3
STARFusionDir=$4
platform=${5:-illumina}

## preprocess
$PRG/ktrim -k $platform -t 6 -o $sid -1 $1 -2 $2 -c | $PRG/krmdup -i /dev/stdin -o $sid.rmdup

## Run STAR-Fusion
$STARFusionDir/STAR-Fusion --left_fq $sid.rmdup.read1.fq --right_fq $sid.rmdup.read2.fq
	--genome_lib_dir $STARFusionDir/GRCh38_gencode_v37_CTAT_lib_Mar012021 \
	--CPU 16 --output_dir $sid.star_fusion

## extract reads supporting fusion events
mkdir -p $sid.supportingReads
perl $PRG/extract.fusion.reads.pl $sid.star-fusion/star-fusion.fusion_predictions.tsv \
	$sid.rmdup.read1.fq $sid.rmdup.read2.fq $sid.supportingReads

