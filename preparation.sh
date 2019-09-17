
#!/bin/bash

# Shortcut to Picardtools
PICARD="/genomics-packages/picard-tools-1.97"

# Create directories
mkdir -p $(dirname "${OUTPUT_DIR}")/grch38_db151 # For variants
mkdir -p $(dirname "${OUTPUT_DIR}")/grch38 # For the ref genome

ls -lhR $(dirname "${OUTPUT_DIR}")

##########################  Variant database ##########################

# Download database
wget https://ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/All_20180418.vcf.gz

ls -lhR $(dirname "${OUTPUT_DIR}")

# Unzip database and move to the right folder
gunzip All_20180418.vcf.gz && mv All_20180418.vcf $(dirname "${OUTPUT_DIR}")/grch38_db151/All_20180418.vcf 

ls -lhR $(dirname "${OUTPUT_DIR}")


##########################   Reference genome ##########################

# Download all files
wget ftp://ftp.ensembl.org/pub/release-87/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.*.fa.gz

ls -lhR $(dirname "${OUTPUT_DIR}")


# Unzip them
gunzip Homo_sapiens.GRCh38.dna.chromosome.*

ls -lhR $(dirname "${OUTPUT_DIR}")


# Append all files in a single file
touch $(dirname "${OUTPUT_DIR}")/grch38/grch38.fa

for CHR in `seq 1 22` X Y MT ; do 
    cat Homo_sapiens.GRCh38.dna.chromosome.${CHR}.fa >> $(dirname "${OUTPUT_DIR}")/grch38/grch38.fa
done

ls -lhR $(dirname "${OUTPUT_DIR}")


##########################   Create Bisulfite-converted genome ##########################


bismark_genome_preparation --bowtie2 --verbose $(dirname "${OUTPUT_DIR}")

ls -lhR $(dirname "${OUTPUT_DIR}")

##########################    Create additional files for Bis-SNP ##########################

# To be used by Bis-SNP, we need to create a dict and *fai file.

# Create the fasta sequence dictionary file. 
# This produces a SAM-style header file describing the contents of our fasta file.

java -jar ${PICARD}/CreateSequenceDictionary.jar \
    R= $(dirname "${OUTPUT_DIR}")/grch38/grch38.fa \
    O= $(dirname "${OUTPUT_DIR}")/grch38/grch38.dict

# Create a fasta index file
# This file describes byte offsets in the fasta file for each contig, allowing us to compute exactly where 
# a particular reference base at contig:pos is in the fasta file.

samtools faidx $(dirname "${OUTPUT_DIR}")/grch38/grch38.fa

ls -lhR $(dirname "${OUTPUT_DIR}")
