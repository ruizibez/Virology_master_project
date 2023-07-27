#!/bin/bash

#SBATCH --job-name=AlignandFilt      #Job name to show with squeue
#SBATCH --output=FileJob_%j.out #Output file
#SBATCH --ntasks=18             #Maximum number of cores to use
#SBATCH --time=3-00:00:00         #Time limit to execute the job (60 minutes)
#SBATCH --mem-per-cpu=50G        #Required Memory per core
#SBATCH --cpus-per-task=10       #CPUs assigned per task.
#SBATCH --qos=medium                     #QoS: short,medium,long,long-mem

#conda activate alignment_venv # All dependencies installed in the venv (HISAT2, gawk, bbmap, bowtie2)


#################################################
#
# This function indexes the reference genome
# via hisat2-build if it is not indexed.
#
# Arguments:
#   Genome fasta file path.
#   Indexed genome path.
#   Number of threads.
#
#################################################

Hisat2IndexGenome () {

    # Arguments
    local genome_path="${1}"
    local path_index_genome="${2}"
    local num_threads="${3}"
    local indexed=false

    # Genome file
    genome_dir=${genome_path%/*}
    genome_file=${genome_path##*/}

    # Check if genome is indexed.
    list_dir_files=$(ls $genome_dir)
    for dir_or_file in $list_dir_files;
    do
        if [[ $dir_or_file = 'Index' ]]
        then
            printf "$genome_file is indexed!\n"
            indexed=true
        fi
    done

    # Index genome using HISAT2
    if [[ $indexed = "false" ]];
    then
        printf "$genome_file is not indexed!\n"
        printf "Indexing $genome_file...\n"
        # Create Index directory
        mkdir -p $path_index_genome
        # Index genome
        hisat2-build -p $num_threads $genome_path $path_index_genome
        printf "DONE!\n"
    fi

}

#################################################
#
# This function aligns a fastq library with a
# previously indexed reference genome (using
# HISAT2) to obtain the unmapped sequences.
#
# Arguments:
#   Genome fasta file path.
#   Indexed genome path.
#   Number of threads.
#
# Return:
#   Unaligned-reads file path
#
#################################################

GetHisat2UnalignedReads() {

    # Arguments
    local path_indexed_genome=$1
    local query_path_r1=$2
    local query_path_r2=$3
    local path_dir_out=$4
    local num_threads=$5

    # Required variables
    base_name=$(basename "$query_path_r1" | sed -E 's/(_1_paired\.fq\.gz|\.1\.fq)$//')

    # Alignment with indexed genome
    hisat2 -x "$path_indexed_genome" \
        -1 "$query_path_r1" \
        -2 "$query_path_r2" \
        -S "$path_dir_out/$output_name_r1.sam" \
        --un-conc "$path_dir_out/unaligned/$base_name".fq \
        --al-conc "$path_dir_out/aligned/$base_name".fq  \
        --threads "$num_threads"

    echo "$path_dir_out/unaligned/$base_name"
}

#################################################
#
# This function aligns a fastq library of HISAT2 
# unaligned reads (reference Cucumis sativus genome)
# to HSVd genome seeking for 100% homology.
#
# Arguments:
#   Genome fasta file path.
#   Indexed genome path.
#   Number of threads.
#
# Return:
#   100% homology aligned-reads file path
#
#################################################


GetBowtie2AlignedReads() {

    # Arguments
    local path_indexed_genome=$1
    local query_path_r1=$2
    local query_path_r2=$3
    local path_dir_out=$4
    local num_threads=$5

    # Required variables
    base_name=$(basename "$query_path_r1" | sed -E 's/(_1_paired\.fq\.gz|\.1\.fq)$//')

    # Alignment with indexed genome
    bowtie2 -a -v 0 -q -1 "$query_path_r1" -2 "$query_path_r2" -S "$path_dir_out/$base_name.sam" --al-conc "$path_dir_out/aligned/$base_name.fq" --threads "$num_threads"

}


### MAIN
main(){

    ## 1. PATHS AND VARIABLES
    ###########################################################################
    # Input paths
    cucumber_path="/home/ruizibez/data/genomes/Cucumber_genome/ChineseLong_genome_v3.fa"
    cucumber_transcriptome_path="/home/ruizibez/data/genomes/Cucumber_transcriptome/ChineseLong_transcriptome_v3.fa"
    hsvd_path="/home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_forward_construct.fasta"
    path_index_cucumber="/home/ruizibez/data/genomes/Cucumber_genome/Index/Cucumber_genome"
    path_index_hsvd="/home/ruizibez/data/genomes/HSVd_genome/Index/HSVd_genome"
    libraries_path="/home/ruizibez/data/01-cucumis_sativus_libraries_clean"

    # Output paths
    alignment_path="/home/ruizibez/results/HisatAlignments"

    # Other variables
    num_threads=20

    ## 2. DISCARD SEQUENCES THAT ALIGN 100% WITH GENOMES (HISAT2)
    ###############################################################################
    # Create directories for the alignment results
    mkdir -p $alignment_path/Cucumber/aligned
    mkdir -p $alignment_path/Cucumber/unaligned
    mkdir -p $alignment_path/HSVd/aligned
    mkdir -p $alignment_path/HSVd/unaligned

    # Check if Cucumber and HSVd genomes are indexed.
    printf "INDEXING GENOMES IF THEY ARE NOT...\n"
    Hisat2IndexGenome $cucumber_path $path_index_cucumber $num_threads
    Hisat2IndexGenome $hsvd_path $path_index_hsvd $num_threads
    printf "DONE!\n"

    # Align libraries with the genomes
    files_path_list=$(ls $libraries_path/*1_paired.fq.gz)
    for R1_path in $files_path_list;
    do
    	R2_path="${R1_path%_1_paired.fq.gz}_2_paired.fq.gz"  # Generate R2 path by replacing '_1_paired.fq.gz' with '_2_paired.fq.gz'
    	printf "File: $R1_path\n"
    	printf "File: $R2_path\n"
    	printf "HISAT2 ALIGNMENT WITH THE CUCUMBER GENOME...\n"
    	cusa_unaligned_reads=$(GetHisat2UnalignedReads $path_index_cucumber $R1_path $R2_path $alignment_path/Cucumber $num_threads)
    	printf "DONE!\n"
    	printf "HISAT2 ALIGNMENT OF THE CUCUMBER-GENOME UNALIGNED SEQUENCES WITH THE HSVd GENOME...\n"
	file_name1="${cusa_unaligned_reads}.1.fq"  
	file_name2="${cusa_unaligned_reads}.2.fq"
    	GetBowtie2AlignedReads $path_index_hsvd $file_name1 $file_name2 $alignment_path/HSVd $num_threads
    	printf "DONE!\n"
    done
}

main "$@"
