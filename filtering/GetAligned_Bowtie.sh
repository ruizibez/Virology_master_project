#!/bin/bash

#SBATCH --job-name=GetBowtieReads      #Job name to show with squeue
#SBATCH --output=FileJob_%j.out #Output file
#SBATCH --ntasks=1             #Maximum number of cores to use
#SBATCH --time=1-00:00:00         #Time limit to execute the job (60 minutes)
#SBATCH --mem-per-cpu=20G        #Required Memory per core
#SBATCH --cpus-per-task=5       #CPUs assigned per task.
#SBATCH --qos=short                     #QoS: short,medium,long,long-mem


input_dir="/home/ruizibez/data/01-cucumis_sativus_libraries_clean"
output_dir_al="/home/ruizibez/results/Endgene_bowtie/aligned"
output_dir_un="/home/ruizibez/results/Endgene_bowtie/unaligned"
path_indexed_genome="/home/ruizibez/results/Endgene_bowtie/Index"
reference="/home/ruizibez/data/genomes/Endogenous_Csgene/Endogenous_Csgene.fasta"
sam_outputdir="/home/ruizibez/results/Endgene_bowtie/sam"
num_threads=4

mkdir -p "$output_dir_al"
mkdir -p "$output_dir_un"
mkdir -p "$path_indexed_genome"
mkdir -p "$sam_outputdir"

module load bowtie2

# Indexar el genoma HSVd
bowtie2-build "$reference" "$path_indexed_genome/Endogenous_Csgene.indexed"
echo "Genoma indexado guardado en: $path_indexed_genome"

# Iterar sobre los archivos R1 en el directorio de entrada
for r1_file in "$input_dir"/*_1_paired.fq; do
    if [[ -f "$r1_file" ]]; then
        # Obtener el nombre base del archivo R1
        base_name=$(basename "$r1_file" _1_paired.fq)

        # Construir las rutas de los archivos R2 correspondientes
        r2_file="$input_dir/${base_name}_2_paired.fq"

        # Verificar si existen los archivos R1 y R2 correspondientes
        if [[ -f "$r2_file" ]]; then
            # Ejecutar el comando bowtie2 para realizar el alineamiento
            bowtie2 -x "$path_indexed_genome/Endogenous_Csgene.indexed" \
                -q -1 "$r1_file" \
                -2 "$r2_file" \
                -S "$sam_outputdir/$base_name.sam" \
                --un-conc "$output_dir_un/$base_name" \
                --al-conc "$output_dir_al/$base_name" \
                --threads "$num_threads"
	
	 # Cambiar la extensión de las salidas de --un-conc a ".fq"
            mv "$output_dir_al/${base_name}.1" "$output_dir_al/${base_name}_1_paired.fq"
            mv "$output_dir_al/${base_name}.2" "$output_dir_al/${base_name}_2_paired.fq"
	    mv "$output_dir_un/${base_name}.1" "$output_dir_un/${base_name}_1_paired.fq"
            mv "$output_dir_un/${base_name}.2" "$output_dir_un/${base_name}_2_paired.fq"
            echo "Procesados archivos R1: $r1_file y R2: $r2_file"
            echo "Resultados guardados en: $output_dir_al/$base_name.sam, $output_dir_un/$base_name y $output_dir_al/$base_name"
            echo
        fi
    fi
done


echo "Proceso completado. Los archivos alineados se han guardado en $output_dir."

