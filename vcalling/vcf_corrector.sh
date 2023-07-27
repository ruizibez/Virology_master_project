#!/bin/bash

#SBATCH --job-name=vcall      #Job name to show with squeue
#SBATCH --output=FileJob_%j.out #Output file
#SBATCH --ntasks=1            #Maximum number of cores to use
#SBATCH --time=1-00:00:00         #Time limit to execute the job (60 minutes)
#SBATCH --mem-per-cpu=30G        #Required Memory per core
#SBATCH --cpus-per-task=10       #CPUs assigned per task.
#SBATCH --qos=short                     #QoS: short,medium,long,long-mem


# Directorio de entrada donde se encuentran los archivos .VCF
directorio_entrada="/home/ruizibez/results/bwa_New_approach/illuminap/test_gatk/test_alnqual_lofreq/test_parameters/no_dup"

# Directorio de salida donde se guardarán los archivos corregidos
directorio_salida="/home/ruizibez/results/bwa_New_approach/illuminap/test_gatk/test_alnqual_lofreq/test_parameters/no_dup"

# Comprobar si el directorio de salida existe, si no, crearlo
if [[ ! -d "$directorio_salida" ]]; then
    mkdir -p "$directorio_salida"
fi

# Recorrer todos los archivos VCF en el directorio de entrada
for archivo_entrada in "$directorio_entrada"/*.vcf; do
    # Verificar si hay archivos que coincidan con el patrón
    [[ -e "$archivo_entrada" ]] || continue

    # Obtener el nombre base del archivo sin la extensión
    nombre_archivo=$(basename "$archivo_entrada")
    nombre_base="${nombre_archivo%.*}"

    # Nombre del archivo de salida
    archivo_salida="${directorio_salida}/corrected_${nombre_base}.vcf"

    # Leer el archivo VCF línea por línea y realizar los ajustes
    while IFS= read -r linea; do
        # Comprobar si la línea es un encabezado o una variante
        if [[ $linea == \#* || $linea == *Variant* ]]; then
            # Escribir la línea sin cambios en el archivo de salida
            echo "$linea" >> "$archivo_salida"
        else
            # Dividir la línea en campos usando tabuladores como separadores
            campos=($linea)
            pos="${campos[1]}"

            # Realizar el ajuste de posición según las reglas dadas
            if (( pos < 150 )); then
                nueva_pos=$(( pos + 148 ))
            else
                nueva_pos=$(( pos - 149 ))
            fi

            # Actualizar la línea con la nueva posición y escribirla en el archivo de salida
            campos[1]=$nueva_pos
            nueva_linea="${campos[*]}"
            echo "$nueva_linea" >> "$archivo_salida"
        fi
    done < "$archivo_entrada"

    echo "Archivo corregido guardado como $archivo_salida"
done

echo "Proceso finalizado."

