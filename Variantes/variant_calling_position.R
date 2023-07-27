# Cargar la librería
library(ggplot2)

# Cargar los datos desde el archivo 'data.csv'
data <- read.csv('data.csv')

# Dividir el archivo en dos datasets según las posiciones 1-148 y 149-297
dataset1 <- data[1:148, ]
dataset2 <- data[149:297, ]

# Barplot normal para el dataset1 (posiciones 1 a 148)
barplot_normal <- ggplot(dataset1, aes(x = Posicion, y = Frecuencia)) +
  geom_bar(stat = 'identity', fill = 'steelblue') +
  labs(x = NULL, y = 'Frecuencia') +  # Quitamos el título del eje X
  ggtitle('Barplot normal (Posiciones 1-148)') +
  ylim(0, 7) +  # Establecer límites en el eje Y hasta el valor 7
  theme_minimal() +
  theme(axis.text.x = element_blank(),  # Ocultamos las etiquetas del eje X
        axis.title.x = element_blank(),  # Ocultamos el título del eje X
        plot.title = element_text(size = 14, face = 'bold'))

# Guardar el primer barplot en alta resolución y apaisado
ggsave('barplot_normal.png', barplot_normal, width = 10, height = 6, dpi = 300)

# Barplot con eje X invertido y valores negativos para el dataset2 (posiciones 149 a 297)
dataset2$Frecuencia_negativa <- -dataset2$Frecuencia

barplot_invertido <- ggplot(dataset2, aes(x = -Posicion, y = Frecuencia_negativa)) +
  geom_bar(stat = 'identity', fill = 'steelblue') +  # Mismo color que el primer plot
  labs(x = NULL, y = 'Frecuencia') +  # Quitamos el título del eje X
  ggtitle('Barplot con eje X y Y invertidos (Posiciones 149-297)') +
  ylim(-7, 0) +  # Establecer límites en el eje Y hasta el valor -7
  theme_minimal() +
  theme(axis.text.x = element_blank(),  # Ocultamos las etiquetas del eje X
        axis.title.x = element_blank(),  # Ocultamos el título del eje X
        plot.title = element_text(size = 14, face = 'bold'))

# Guardar el segundo barplot en alta resolución y apaisado
ggsave('barplot_invertido.png', barplot_invertido, width = 10, height = 6, dpi = 300)
