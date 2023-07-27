# Cargar el paquete necesario para la manipulación de datos
library(dplyr)

# Especificar la ruta y nombre del archivo de entrada
ruta_archivo <- "/home/miguel/G3/test/illuminap/pysamstats/illuminap_pysamstats_var_R00_3_912_42.csv"

# Leer el archivo de datos
datos <- read.csv(ruta_archivo, header = TRUE)

# Modificar la columna "pos" según las condiciones dadas
datos$pos <- ifelse(datos$pos >= 150, datos$pos - 149, datos$pos + 148)


# Agrupar los datos por el valor de la columna "pos" y sumar las columnas especificadas
datos_agrupados <- datos %>%
  filter(!is.na(chrom) & !is.na(pos) & !is.na(ref)) %>%
  group_by(chrom, pos, ref) %>%
  summarise(
    reads_all = sum(reads_all),
    reads_pp = sum(reads_pp),
    matches = sum(matches),
    matches_pp = sum(matches_pp),
    mismatches = sum(mismatches),
    mismatches_pp = sum(mismatches_pp),
    deletions = sum(deletions),
    deletions_pp = sum(deletions_pp),
    insertions = sum(insertions),
    insertions_pp = sum(insertions_pp),
    A = sum(A),
    A_pp = sum(A_pp),
    C = sum(C),
    C_pp = sum(C_pp),
    T = sum(T),
    T_pp = sum(T_pp),
    G = sum(G),
    G_pp = sum(G_pp),
    N = sum(N),
    N_pp = sum(N_pp)
  )



# Especificar la ruta y nombre del archivo de salida
ruta_salida <- "/home/miguel/G3/test/illuminap/pysamstats/sorted/sorted_illuminap_var_R00_3_912_42.csv"

# Guardar los datos agrupados en un nuevo archivo CSV
write.csv(datos_agrupados, file = ruta_salida, row.names = FALSE)
