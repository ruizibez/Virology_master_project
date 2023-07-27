#!/bin/bash

#SBATCH --job-name=bwa_autalignment         # Job name.
#SBATCH -n 1                           # Number of cores requested
#SBATCH -N 4                           # Number of nodes requested
#SBATCH -t 200:00                      # Runtime in minutes.
#SBATCH --qos medium                    # The QoS to submit the job.
#SBATCH --mem=10G                      # Memory per cpu in G (see also --mem-per-cpu)
#SBATCH -o hostname_%j.out             # Standard output goes to this file
#SBATCH -e hostname_%j.err             # Standard error goes to this file



# Directorio de entrada
input_dir="/home/ruizibez/results/bwa_New_approach/pysamstats_and_R/illuminap/pysamstats/bwaN_test"

# Directorio de salida
output_dir="/home/ruizibez/results/bwa_New_approach/pysamstats_and_R/illuminap/pysamstats/bwaN_test/pysamstats"

# Ruta al archivo FASTA de referencia
reference_file="/home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_construct.fasta"

# Iterar sobre cada archivo terminado en 'sorted.bam' en el directorio de entrada
for bam_file in "$input_dir"/*sorted.bam; do
    # Obtener el nombre base del archivo sin la extensión
    base_name=$(basename "$bam_file" .sorted.bam)

    # Ruta completa de salida para el archivo de resultados
    output_file="$output_dir/test_illumina_pysamstats_var_${base_name}.txt"

    # Indexar el archivo BAM
    samtools index "$bam_file"

    # Aplicar pysamstats al archivo BAM
    pysamstats -f "$reference_file" --type variation "$bam_file" > "$output_file"
done

