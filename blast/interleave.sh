#!/bin/bash

#SBATCH --job-name=interleave_and_fq2fa      #Job name to show with squeue
#SBATCH --output=FileJob_%j.out #Output file
#SBATCH --ntasks=1             #Maximum number of cores to use
#SBATCH --time=1-00:00:00         #Time limit to execute the job (60 minutes)
#SBATCH --mem-per-cpu=20G        #Required Memory per core
#SBATCH --cpus-per-task=5       #CPUs assigned per task.
#SBATCH --qos=short                     #QoS: short,medium,long,long-mem

#conda activate alignment_venv #necesario para usar bbmap y poder hacer el reformat.sh para el interleave.


directory="/home/ruizibez/results/Endgene_bowtie/unaligned"  # Ruta al directorio donde se encuentran los archivos
directory2="/home/ruizibez/results/Endgene_bowtie/unaligned/interleave"

# Buscar archivos que terminan en '1.fq'
files_1=("$directory"/*_1_paired.fq)

for file_1 in "${files_1[@]}"; do
    # Obtener el prefijo del archivo
    prefix=$(basename "$file_1" _1_paired.fq)

    # Buscar archivo correspondiente que termina en '2.fq'
    file_2="$directory/$prefix"_2_paired.fq

    # Verificar si el archivo existe
    if [ -f "$file_2" ]; then
        # Ejecutar el comando reformat.sh
        output_file="${prefix}_interleave.fq"
        reformat.sh in1="$file_1" in2="$file_2" out="$directory2/$output_file"

        echo "Archivo procesado: $file_1, $file_2"
        echo "Salida FASTQ: $directory2/$output_file"
        echo

        # Convertir archivo FASTQ a FASTA
        #fasta_file="${prefix}_interleave.fasta"
        #sed -n '1~4s/^@/>/p;2~4p' "$directory2/$output_file" > "$directory2/$fasta_file"
        #echo "Salida FASTA: $directory2/$fasta_file"
        #echo

    else
        echo "No se encontró el archivo correspondiente a $file_1: $file_2"
        echo
    fi
done


