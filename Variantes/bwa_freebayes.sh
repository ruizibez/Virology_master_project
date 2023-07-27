#!/bin/bash

#SBATCH --job-name=vcall      #Job name to show with squeue
#SBATCH --output=FileJob_%j.out #Output file
#SBATCH --ntasks=1            #Maximum number of cores to use
#SBATCH --time=1-00:00:00         #Time limit to execute the job (60 minutes)
#SBATCH --mem-per-cpu=30G        #Required Memory per core
#SBATCH --cpus-per-task=10       #CPUs assigned per task.
#SBATCH --qos=short                     #QoS: short,medium,long,long-mem


# Ruta al directorio con los archivos de entrada
directorio_entrada="/home/ruizibez/results/bwa/illuminap"

# Ruta al archivo del genoma de referencia
archivo_referencia="/home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_construct.fasta"

# Ruta al directorio de salida
directorio_salida="/home/ruizibez/results/bwa_New_approach/illuminap/test_vcall/vcf_files_freebayesmoddef"

# Crear el directorio de salida si no existe
mkdir -p "$directorio_salida"

# Iterar sobre cada archivo en el directorio
for archivo in "$directorio_entrada"/*sorted.bam; do
    # Verificar que el archivo sea válido
    if [[ -f "$archivo" ]]; then
        # Obtener el nombre base del archivo sin la extensión
        nombre_base=$(basename "$archivo" .bam)

        # Generar la ruta completa de salida
        ruta_salida="$directorio_salida/$nombre_base.vcf"

        # Aplicar el comando de FreeBayes
	freebayes -f "$archivo_referencia" "$archivo" --min-alternate-fraction 0.005 --min-repeat-entropy 1 --no-partial-observations --pooled-discrete -p 50 -v "$ruta_salida"
    fi
done


