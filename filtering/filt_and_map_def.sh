#!/bin/bash

#SBATCH --job-name=filt_and_map      # Nombre del trabajo para mostrar con squeue
#SBATCH --output=filt_and_map_%j.out # Archivo de salida
#SBATCH --ntasks=10                  # Número máximo de núcleos a utilizar
#SBATCH --time=00:90:00              # Límite de tiempo para ejecutar el trabajo (90 minutos)
#SBATCH --mem-per-cpu=10G            # Memoria requerida por núcleo
#SBATCH --cpus-per-task=1            # CPUs asignados por tarea
#SBATCH --qos=short                  # QoS: short,medium,long,long-mem

# Se cargan los módulos necesarios
module load bwa
module load samtools
#module load mafft

# Directorio de entrada
input_dir="/home/ruizibez/data/results_blast_alt/Homology_results"

# Directorio de salida
output_dir="/home/ruizibez/data/alt"

# Archivo de referencia para el mapeado
reference="/home/ruizibez/workspace/mapping/HSVd_reference_forward.fasta"

# Función para procesar cada archivo
process_file() {
    file="$1"
    filename=$(basename "$file")
    filename_without_ext="${filename%.paired.txt}"

    # Comprobar si el archivo es un archivo de texto
    if [[ "$filename" == *".paired.txt" ]]; then
        # Procesar el archivo usando los comandos proporcionados
        cat "$file" | awk -F "," '{if ($3 != 0) print $1}' > "$output_dir/$filename_without_ext"_blastid.txt
        cat "$output_dir/$filename_without_ext"_blastid.txt | sed 's/_/ /g' > "$output_dir/$filename_without_ext"_blastid_mod.txt
        seqkit grep -n -f "$output_dir/$filename_without_ext"_blastid_mod.txt "$output_dir/$filename_without_ext"_paired.fa -o "$output_dir/$filename_without_ext"_filt.fa
        fasta_formatter -i "$output_dir/$filename_without_ext"_filt.fa -o "$output_dir/$filename_without_ext"_filt_format.fa
        fastx_collapser -i "$output_dir/$filename_without_ext"_filt_format.fa -o "$output_dir/$filename_without_ext"_collapsed.fa

        #mafft --add /home/ruizibez/data/HSVd_reference_forward_dimero.fasta --reorder "$output_dir/$filename_without_ext"_collapsed.txt > "$output_dir/$filename_without_ext"_with_HSVd.txt

        # Empaquetamos resultados en una carpeta para luego pasar a local y visualizar con IGV
        mkdir -p "$output_dir/$filename_without_ext"
        cp "$output_dir/$filename_without_ext"_collapsed.fa "$output_dir/$filename_without_ext"
        cp /home/ruizibez/workspace/alt_mapping/HSVd_reference_forward* "$output_dir/$filename_without_ext"

        # Mapeo utilizando bwa
        cd "$output_dir/$filename_without_ext"
        bwa index "$reference"
        bwa mem "$reference" "$filename_without_ext"_collapsed.fa > "$filename_without_ext"_mon.sam

        # Convertir el archivo SAM a formato BAM utilizando samtools
        samtools view -S -b "$filename_without_ext"_mon.sam > "$filename_without_ext"_mon.bam

        # Ordenar y generar índice para el archivo BAM
        samtools sort "$filename_without_ext"_mon.bam -o "$filename_without_ext".sorted_mon.bam
        samtools index "$filename_without_ext".sorted_mon.bam
    fi
}

# Iterar sobre todos los archivos en el directorio de entrada
for file in "$input_dir"/*.paired.txt; do
    process_file "$file"
done

