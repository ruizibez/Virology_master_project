#!/bin/bash

#SBATCH --job-name=bwa_autalignment         # Job name.
#SBATCH -n 1                           # Number of cores requested
#SBATCH -N 8                           # Number of nodes requested
#SBATCH -t 4320:00                      # Runtime in minutes.
#SBATCH --qos medium                    # The QoS to submit the job.
#SBATCH --mem=60G                      # Memory per cpu in G (see also --mem-per-cpu)
#SBATCH -o hostname_%j.out             # Standard output goes to this file
#SBATCH -e hostname_%j.err             # Standard error goes to this file

module load bwa
module load samtools


directorio="/home/ruizibez/results/HisatAlignments/Cucumber/unaligned/fasta_files"  # Ruta al directorio que contiene los archivos
out_dir="/home/ruizibez/results/bwa/illuminap"

mkdir -p "$out_dir"

# Recorre todos los archivos del directorio que terminen en '.1.fasta'
for archivo_1 in "$directorio"/*.1.fasta; do
    if [ -f "$archivo_1" ]; then
        # Obtener el nombre base del archivo 1
        nombre_base=$(basename "$archivo_1" .1.fasta)

        # Generar el nombre del archivo 2
        archivo_2="${nombre_base}.2.fasta"

        # Verificar si el archivo 2 existe
        if [ -f "$directorio/$archivo_2" ]; then
            # Ejecutar los comandos deseados
	    echo "$directorio/$archivo_2"
            # Comandos deseados:
            bwa index /home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_construct.fasta
            bwa mem /home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_construct.fasta "$archivo_1" "$directorio/$archivo_2" > "${out_dir}/${nombre_base}.bwa.sam"
            samtools sort -O bam -o "${out_dir}/${nombre_base}.bwa.sorted.bam" "${out_dir}/${nombre_base}.bwa.sam"

        fi
    fi
done

