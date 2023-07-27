#!/bin/bash

#SBATCH --job-name=HisatandFilt      #Job name to show with squeue

#SBATCH --output=FileJob_%j.out #Output file

#SBATCH --ntasks=1             #Maximum number of cores to use

#SBATCH --time=1-00:00:00         #Time limit to execute the job (60 minutes)

#SBATCH --mem-per-cpu=15G        #Required Memory per core

#SBATCH --cpus-per-task=20       #CPUs assigned per task.

#SBATCH --qos=short                     #QoS: short,medium,long,long-mem

conda activate alignment_venv # All dependencies installed in the venv (HISAT2, gawk, bbmap)



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

GetHisat2UnalignedReads () {

    # Arguments
    local path_indexed_genome=$1
    local query_path=$2
    local path_dir_out=$3
    local num_threads=$4

    # Required variables
    file_name=${query_path##*/}
    out_name=${file_name%.fq*}

    # Alignment with Cucumber genome
    hisat2 -x $path_indexed_genome \
        -U $query_path \
        -S $path_dir_out/$out_name.sam \
        --un-conc $path_dir_out/unaligned/$out_name.fq \
        --al-conc $path_dir_out/aligned/$out_name.fq \
        --threads $num_threads

    echo $path_dir_out/unaligned/$out_name.fq
}



### MAIN
main(){

    ## 1. PATHS AND VARIABLES
    ###########################################################################
    # Input paths
    cucumber_path="/home/ruizibez/data/genomes/Cucumber_genome/ChineseLong_genome_v3.fa"
    cucumber_transcriptome_path="/home/ruizibez/data/genomes/Cucumber_transcriptome/ChineseLong_transcriptome_v3.fa"
    hsvd_path="/home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_forward_dimero.fasta"
    path_index_cucumber="/home/ruizibez/data/genomes/Cucumber_genome/Index/Cucumber_genome"
    path_index_hsvd="/home/ruizibez/data/genomes/HSVd_genome/Index/HSVd_genome"
    libraries_path="/home/ruizibez/data/01-cucumis_sativus_libraries_clean"

    # Output paths
    alignment_path="/home/ruizibez/results/HisatAlignments"
   # blast_path="/home/ruizibez/results/HisatAlignments/Homology_analysis_Cucumber_HSVd/BlastAlignments"
   # tables_path="/home/ruizibez/results/HisatAlignments/Homology_analysis_Cucumber_HSVd/Homology_results"

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
    files_path_list=$(ls $libraries_path)
    for R_path in $files_path_list;
    do
        printf "File: $R_path\n"
        printf "HISAT2 ALIGNMENT WITH THE CUCUMBER GENOME...\n"
        cusa_unaligned_reads=$(GetHisat2UnalignedReads $path_index_cucumber $R_path $alignment_path/Cucumber $num_threads)
        printf "DONE!\n"
        printf "HISAT2 ALIGNMENT OF THE CUCUMBER-GENOME UNALGIGNED SEQUENCES WITH THE HSVd GENOME...\n"
        GetHisat2UnalignedReads $path_index_hsvd $cusa_unaligned_reads $alignment_path/HSVd $num_threads
        printf "DONE!\n"
    done

   

main "$@"
