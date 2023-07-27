import os
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Crear los datos de ejemplo
replicas = ["Sample 1", "Sample 2", "Sample 3"]
tiempos = ["T1", "T2", "T3"]
magnitud_cambio = [0, 2.9411765, 2.8251599, 2.3791357, 4.1935558, 4.0932859, 3.3695358, 2.141527, 2.6944251]

# Crear una matriz con los valores de magnitud de cambio
valores = np.array(magnitud_cambio).reshape(len(replicas), len(tiempos))

# Crear las coordenadas X, Y y Z para el histograma
coord_x, coord_y = np.meshgrid(np.arange(len(replicas)), np.arange(len(tiempos)))
coord_x = coord_x.flatten()
coord_y = coord_y.flatten()
coord_z = np.zeros_like(coord_x)
valores_flatten = valores.flatten()

# Configurar la figura y los ejes en 3D
fig = plt.figure()
ax = fig.add_subplot(111, projection="3d")

# Crear el histograma en 3D con colores específicos para cada réplica
colors = ["#FFCCCC", "#CCFFCC", "#CCCCFF"]
for i, val in enumerate(valores_flatten):
    replica_index = coord_x[i]
    color = colors[replica_index]
    ax.bar3d(coord_x[i], coord_y[i], coord_z[i], dx=0.5, dy=0.5, dz=val, color=color, edgecolor="black")

# Configurar etiquetas de los ejes
ax.set_xticks(np.arange(len(replicas)) + 0.25)
ax.set_xticklabels(replicas)
ax.set_yticks(np.arange(len(tiempos)) + 0.25)
ax.set_yticklabels(tiempos)
ax.set_xlabel("Samples")
ax.set_ylabel("Time")
ax.set_zlabel("Homologue/Non-homologue (%)")

# Guardar el gráfico en el directorio de ejecución
nombre_archivo = "histograma_3D.png"
ruta_guardado = os.path.join(os.getcwd(), nombre_archivo)
plt.savefig(ruta_guardado)

# Mostrar el gráfico
plt.show()

