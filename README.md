### Programs and scripts to analyze RNA fusions in placentae (Zhang et al.).
---
Distributed under the [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/ "CC BY-NC-ND")
license for **personal and academic usage only.**

### The following software are required:
1. bwa
2. samtools
3. STAR-Fusion, with the 'GRCh38_gencode_v37_CTAT_lib_Mar012021' annotation
4. Trinity, which requires jellyfish and salmon

### Step 1: data preprocessing and run STAR-Fusion
The program is `1.preprocess.and.run.STAR-Fusion.sh`, run it without parameters to see the usage:
```
user@linux$ sh 1.preprocess.and.run.STAR-Fusion.sh

Usage: 1.preprocess.and.run.STAR-Fusion.sh <read1.fq[.gz]> <read2.fq[.gz]> <output.prefix> <STAR-Fusion.dir> [platform=illumina]
Note: You need to download the 'GRCh38_gencode_v37_CTAT_lib_Mar012021' annotation and put it to STAR-Fusion's directory.
```
The first 2 parameters are paired RNA-seq read files (gzipped files are supported), the 3rd parameter is the output directory you
want to use, the 4th parameter is the directory of `STAR-Fusion` where you should download the `GRCh38_gencode_v37_CTAT_lib_Mar012021`
annotation and put into, the 5th parameter is the sequencing platform (you can leave it empty for illumina sequencers).

This program will generate 2 directories: `XXX.star_fusion` for STAR-Fusion outputs, and `XXX.supportingReads` for reads supporting
the fusion events identified by STAR-Fusion, where the `XXX` is the 3rd parameter. We ran this script on all samples separately.

### Step 2: run Trinity using reads supporting fusion events
The program is `2.run.trinity.sh`, run it without parameters to see the usage:
```
user@linux$ sh 2.run.trinity.sh

Usage: 2.run.trinity.sh <supporting.read1.fq> <supporting.read2.fq> </path/to/trinity> <out.Trinity.dir>
You may need to concatenate the supporting reads for each fusion gene from different samples first.
Trinity requires the output.dir to contain the word 'trinity', so I will add it if necessary.
```
The first 2 parameters are paired RNA-seq read files that supports a specific fusion event, the 3rd parameter is the path to Trinity
program, and the 4th parameters is the output directory you want to use. For each fusion event called by `STAR-Fusion`, we pooled the
supporting reads from different samples and ran this script to assemble its sequence around the fusion junction.

The main output is the `fusion.assembly.fa` file under the `out.Trinity.dir` parameter.

### Step 3: re-align the RNA-seq reads to Trinity assembly for manual inspections
The program is `3.check.assembly.sh`, run it without parameters to see the usage:
```
user@linux$ sh 3.check.assembly.sh 

Usage: 3.check.assembly.sh <supporting.read1.fq> <supporting.read2.fq> </path/to/genome.fa> <trinity.out.dir>
You may need to manually check the results using IGV or UCSC genome browser.
```
The first 2 parameters are paired RNA-seq read files that supports a specific fusion event, the 3rd parameter is the path to human
genome in fasta or 2bit format, and the 4th parameter is the Trinity's output directory. This script will generate several `bed` and `bam`
format files which you can visualize using IGV or UCSC Genome Browser to manually check the reliablity of the fusion events.

