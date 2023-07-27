ruta_archivot1 <- "/home/miguel/G3/test/illuminap/pysamstats/sorted/sorted_illuminap_var_R00_1_36_3.csv"
ruta_archivot2 <- "/home/miguel/G3/test/illuminap/pysamstats/sorted/sorted_illuminap_var_R00_2_36_21.csv"
ruta_archivot3 <- "/home/miguel/G3/test/illuminap/pysamstats/sorted/sorted_illuminap_var_R00_3_36_39.csv"

# Leer los archivos CSV para los tres tiempos
tiempo1 <- read.csv(ruta_archivot1)
tiempo2 <- read.csv(ruta_archivot2)
tiempo3 <- read.csv(ruta_archivot3)

# Extraer las columnas 'pos', 'mismatches' y 'matches' de cada tiempo
pos_tiempo1 <- tiempo1$pos
mismatches_tiempo1 <- tiempo1$mismatches
matches_tiempo1 <- tiempo1$matches

pos_tiempo2 <- tiempo2$pos
mismatches_tiempo2 <- tiempo2$mismatches
matches_tiempo2 <- tiempo2$matches

pos_tiempo3 <- tiempo3$pos
mismatches_tiempo3 <- tiempo3$mismatches
matches_tiempo3 <- tiempo3$matches

# Multiplicar la relación 'mismatches/matches' por 100
relacion_tiempo1 <- 100 * (mismatches_tiempo1 / matches_tiempo1)
relacion_tiempo2 <- 100 * (mismatches_tiempo2 / matches_tiempo2)
relacion_tiempo3 <- 100 * (mismatches_tiempo3 / matches_tiempo3)

# Crear el gráfico de relación entre 'mismatches' y 'matches' (porcentaje) para cada valor de 'pos'
plot(pos_tiempo1, relacion_tiempo1, type = "b", pch = 16, col = "#FFCCCC",
     xlab = "pos", ylab = "Relación (mismatches/matches) %",
     main = "Relación de 'mismatches' entre 'matches'",
     xlim = range(c(pos_tiempo1, pos_tiempo2, pos_tiempo3)),
     ylim = range(c(relacion_tiempo1, relacion_tiempo2, relacion_tiempo3)))

lines(pos_tiempo2, relacion_tiempo2, type = "b", pch = 16, col = "#CCFFCC")
lines(pos_tiempo3, relacion_tiempo3, type = "b", pch = 16, col = "#CCCCFF")

# Agregar una leyenda
legend("topright", legend = grupos, col = c("#FFCCCC", "#CCFFCC", "#CCCCFF"), pch = 16)
