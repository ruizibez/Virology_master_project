#!/bin/bash

#SBATCH --job-name=vcall      #Job name to show with squeue
#SBATCH --output=FileJob_%j.out #Output file
#SBATCH --ntasks=1            #Maximum number of cores to use
#SBATCH --time=1-00:00:00         #Time limit to execute the job (60 minutes)
#SBATCH --mem-per-cpu=30G        #Required Memory per core
#SBATCH --cpus-per-task=10       #CPUs assigned per task.
#SBATCH --qos=short                     #QoS: short,medium,long,long-mem


#####################################################################################################################################
# ES NECESARIO AÑADIR PRIMERO VALOR DE CALIDAD A LAS INDELS:									    #
#	lofreq alnqual -b /home/ruizibez/results/bwa_New_approach/illuminap/test_gatk/R00_2_14_markeddups.sorted.bam \              #
#       	/home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_construct.fasta | samtools sort - > R00_2_14_alnq.sorted.bam #
#																    #	
#####################################################################################################################################

# Ruta al directorio con los archivos de entrada
directorio_entrada="/home/ruizibez/results/bwa/illuminap"

# Ruta al archivo del genoma de referencia
archivo_referencia="/home/ruizibez/data/genomes/HSVd_genome/HSVd_reference_construct.fasta"

# Ruta al directorio de salida
directorio_salida="/home/ruizibez/results/bwa/illuminap/variant_calling/test_bwaN"

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

        # Aplicar el comando de LoFreq
	lofreq call -N --call-indels -f "$archivo_referencia" -o "$ruta_salida" "$archivo"
    fi
done


