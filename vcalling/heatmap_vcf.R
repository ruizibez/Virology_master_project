setwd("/home/miguel/G3/Bioinformatics/mapping/New_approach/vcalling")

# Cargar la biblioteca ggplot2
library(ggplot2)

# Definir los nombres de los archivos de entrada
archivos <- c("SNV_R00_1_36_3.bwa.sorted.vcf", "SNV_R00_2_14_19.bwa.sorted.vcf", "SNV_R00_2_25_20.bwa.sorted.vcf", "SNV_R00_2_36_21.bwa.sorted.vcf", "SNV_R00_3_14_37.bwa.sorted.vcf", "SNV_R00_3_25_38.bwa.sorted.vcf", "SNV_R00_3_36_39.bwa.sorted.vcf")

# Crear una matriz de ceros con 297 filas y 7 columnas
matriz_datos <- matrix(0, nrow = 297, ncol = 7)

# Recorrer los archivos y actualizar la matriz de datos con los valores encontrados
for (i in 1:length(archivos)) {
  datos <- scan(archivos[i], what = numeric(), sep = "\n")
  valores <- as.numeric(datos)
  matriz_datos[valores, i] <- 1
}

# Definir las etiquetas de los ejes
etiquetas_y <- seq(1, 297, 8)
etiquetas_x <- c("R00_1_36", "R00_2_14", "R00_2_25", "R00_2_36", "R00_3_14", "R00_3_25", "R00_3_36")

# Crear un data frame con los datos de la matriz
df <- expand.grid(x = etiquetas_x, y = seq(1, nrow(matriz_datos)), stringsAsFactors = FALSE)
df$value <- as.vector(t(matriz_datos))

# Definir una paleta de colores azules para un heatmap binario
colores <- c("#ADD8E6", "#4169E1")  # Azul claro y azul medio

# Crear el heatmap utilizando ggplot2 y geom_tile()
plot <- ggplot(df, aes(x = x, y = y, fill = factor(value))) +
  geom_tile(color = "white") +
  scale_fill_manual(values = colores, name = "Valor") +
  labs(title = "Heatmap", x = "", y = "Posición") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8)) +
  scale_y_continuous(breaks = etiquetas_y)

# Guardar el plot en alta resolución (300 píxeles por pulgada) en formato PNG
ggsave("heatmap.png", plot, dpi = 300)
