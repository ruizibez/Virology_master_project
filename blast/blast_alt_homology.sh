#!/bin/bash

#SBATCH --job-name=Blastn_var      #Job name to show with squeue
#SBATCH --output=FileJob_%j.out #Output file
#SBATCH --ntasks=1             #Maximum number of cores to use
#SBATCH --time=1-00:00:00         #Time limit to execute the job (60 minutes)
#SBATCH --mem-per-cpu=40G        #Required Memory per core
#SBATCH --cpus-per-task=10       #CPUs assigned per task.
#SBATCH --qos=short                     #QoS: short,medium,long,long-mem


#conda activate alignment_venv #Aquí están instaladas todas las dependencias (blast, gawk)


### FUNCTIONS

#################################################
#
# This function converts a fastq file to fasta.
#
# Arguments:
#   Fastq file path
#
# Return:
#   Fasta file path
#
#################################################

Fastq2Fasta () {

    # Arguments
    local file_path="${1}"

    # Get fasta file name
    if [[ $file_path =~ \.fq$ ]]
    then
        fasta=${file_path%.fq}.fasta

    elif [[ $file_path =~ \.fastq$ ]]
    then

        fasta=${file_path%.fastq}.fasta
    fi

    # Convert fastq to fasta
    sed -n '1~4s/^@/>/p;2~4p' $file_path | sed 's/ /_/g' > $fasta
    echo "$fasta"

}

#################################################
#
# This function align against the reference
# transcriptome/genome those sequences that
# have not mapped against either of the 2
# genomes used. It then filters the matches
# obtained by selecting those sequences with
# the highest percentage of identity (discarding
# the perfect matches not detected by HISAT).
#
# Arguments:
#   Genome fasta file path.
#   Indexed genome path.
#   Output directory path.
#   Number of threads.
#
# Returns:
#   Output file path.
#
#################################################

GetHomologuesList () {

    # Arguments
    local database_path="${1}"
    local query_path="${2}"
    local blast_dir_out="${3}"
    local num_threads="${4}"


    # Required variables
    #file_name=${R1_path#*unaligned/}
    file_name=${query_path##*/} 
    out_name=${file_name%.fasta}

    # Execute Blast
    blastn \
        -task blastn \
        -db $database_path \
        -query $query_path \
        -qcov_hsp_perc 100 \
        -num_threads $num_threads \
        -outfmt '6 qseqid pident evalue' \
        -out $blast_dir_out/$out_name"_blast.txt"
    
    # Get the best match
    gawk '{if(a[$1]<$2 && b[$1]<$3 && $3<0.05){a[$1]=$2; b[$1]=$3}}END{for(i in a){print i","a[i]","b[i];}}' $blast_dir_out/$out_name"_blast.txt" | sort -t',' -k1,1 > $blast_dir_out/$out_name"_blast_bestmatch.csv"
    
    # Delete perfect matches (not detected by Hisat2) and matches with evalue > 0.05
    gawk -F "," '{if($2 != 100.000 && $2 != "" ){print}}' $blast_dir_out/$out_name"_blast_bestmatch.csv" > $blast_dir_out/$out_name"_blast_bestmatch_filt.csv"

    echo $blast_dir_out/$out_name"_blast_bestmatch_filt.csv"

}


### MAIN
main(){

    ## 1. PATHS AND VARIABLES
    ###########################################################################
    # Input paths
    cucumber_path="/home/ruizibez/data/genomes/Cucumber_genome/ChineseLong_genome_v3.fa"
    cucumber_transcriptome_path="/home/ruizibez/data/genomes/Cucumber_transcriptome/ChineseLong_transcriptome_v3.fa"
    hsvd_path="/home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_construct.fasta"
    path_index_cucumber="/home/ruizibez/data/genomes/Cucumber_genome/Index/Cucumber_genome"
    path_index_hsvd="/home/ruizibez/data/genomes/HSVd_genome/Index/HSVd_genome"
    libraries_path="/home/ruizibez/data/01-cucumis_sativus_libraries_clean"

    # Output paths
    alignment_path="/home/ruizibez/results/HisatAlignments"
    blast_path="/home/ruizibez/results/Homology_alignments/BlastAlignments"
    tables_path="/home/ruizibez/results/Homology_alignments/Homology_results"

    # Other variables
    num_threads=20

	    ## 2. GET IDENTITY PERCENTAGE OF UNALIGNED SEQUENCES (BLASTN)
    ###############################################################################

    # Create Cucumber and HSVd genomes databases directory
    mkdir -p $blast_path/Blast_databases/Cucumber
    mkdir -p $blast_path/Blast_databases/HSVd

    # Create Blast results directory
    mkdir -p $blast_path/Results/Cucumber/
    mkdir -p $blast_path/Results/HSVd/

    # Create resutls directory
    mkdir -p $tables_path

    # Make cucumber transcriptome Blast database
   # printf "\n\nMAKING CUCUMBER TRANSCRIPTOME BLAST DATABASE...\n"
    # cucumber_blast_db=$blast_path/Blast_databases/Cucumber/Cucumber_blast_transcriptome
    # makeblastdb -in $cucumber_transcriptome_path -dbtype nucl -input_type fasta -out $cucumber_blast_db

    # Make viroid genome Blast database
    printf "\n\nMAKING HSVd GENOME BLAST DATABASE...\n"
    hsvd_blast_db=$blast_path/Blast_databases/HSVd/HSVd_blast_genome
    makeblastdb -in $hsvd_path -dbtype nucl -input_type fasta -out $hsvd_blast_db

    # Make Blast using the sequences that have not aligned with any genome.
    fastq_paths_list=$(ls /home/ruizibez/results/HisatAlignments/HSVd/bowtie/unaligned/interleave/*.fq)  

    for fastq in $fastq_paths_list
    do
       
        # Convert fastq to fasta
        fasta_file=$(Fastq2Fasta $fastq)

        # Get homologues list (cucumber genome)
      # printf "\n\nMAKING BLAST TO THE CUCUMBER TRANSCRIPTOME USING UNALIGNED SEQUENCES...\n"
        #cusa_id_file=$(GetHomologuesList $cucumber_blast_db $fasta_file $blast_path/Results/Cucumber $num_threads)

        # Get homologues list (HSVd genome)
        printf "\n\nMAKING BLAST TO THE HSVd GENOME USING UNALIGNED SEQUENCES...\n"
        hsvd_id_file=$(GetHomologuesList $hsvd_blast_db $fasta_file $blast_path/Results/HSVd $num_threads)

        # Sorted files names
        #cusa_id_sort=${cusa_id_file%.csv}_sorted.csv 
        hsvd_id_sort=${hsvd_id_file%.csv}_sorted.csv

        # Sort files by join column
        #sort -k 1b,1 -t "," $cusa_id_file -o $cusa_id_sort
        sort -k 1b,1 -t "," $hsvd_id_file -o $hsvd_id_sort

        # Join both files
        printf "\n\nJOINING RESULTS FROM BOTH ALIGNMENTS...\n"
       # join -1 1 -2 1 -t , -o 0,1.2,2.2 -a 1 -a 2 -e 0 $cusa_id_sort $hsvd_id_sort > $tables_path/$out_name.txt
	join -1 1 -2 1 -t , -o 0,1.2,2.2 -a 1 -a 2 -e 0 $hsvd_id_sort > $tables_path/$out_name.txt
        printf $file_name" done!\n"
    done
}

main "$@"
