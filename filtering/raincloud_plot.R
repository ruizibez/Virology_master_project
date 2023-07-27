library(ggplot2)
library(ggdist)
library(tidyverse)
library(gridExtra)

# Read the first data file
data1 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/end_gene/R00_1_interleave_blast_bestmatch_filt.csv", header = FALSE, sep=',')

# Read the second data file
data2 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/end_gene/R00_2_interleave_blast_bestmatch_filt.csv", header = FALSE, sep=',')

# Read the third data file
data3 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/end_gene/R00_3_interleave_blast_bestmatch_filt.csv", header = FALSE, sep=',')

# Assign colors to each data group
colors <- c("#FFCCCC", "#CCFFCC", "#CCCCFF")

# Function to create raincloud plot for a single data frame
create_raincloud_plot <- function(data, title, color) {
  # Create the raincloud plot
  ggplot(data, aes(x = factor(1), y = V2, fill = factor(1))) +
    stat_halfeye(
      adjust = 0.5,
      justification = -0.2,
      .width = 0,
      point_colour = NA
    ) +
    geom_boxplot(
      width = 0.12,
      outlier.color = NA,
      alpha = 0.5
    ) +
    stat_dots(
      side = "left",
      justification = 1.1,
      binwidth = 0.25
    ) +
    scale_fill_manual(values = color) +
    labs(
      title = ifelse(title == "", NULL, title),
      x = NULL,
      y = ifelse(title == "", NULL, "Porcentaje de identidad (%)"),
      fill = NULL
    ) +
    coord_flip() +
    scale_y_reverse(limits = c(100, 70)) +
    theme_bw() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      axis.text.y = element_text(margin = margin(r = 10)),
      axis.title.y = element_text(margin = margin(r = 20))
    )
}

# Create the raincloud plots for each data frame
plot1 <- create_raincloud_plot(data1, "Tiempo 1", colors[1])
plot2 <- create_raincloud_plot(data2, "Tiempo 2", colors[2])
plot3 <- create_raincloud_plot(data3, "Tiempo 3", colors[3])

# Adjust the width of plots 2 and 3 to match plot 1
plot2 <- plot2 + theme(plot.margin = margin(l = 0, r = 0.5, b = 0, t = 0))
plot3 <- plot3 + theme(plot.margin = margin(l = 0, r = 0.5, b = 0, t = 0))

# Combine the plots using arrangeGrob()
combined_plot <- gridExtra::arrangeGrob(plot1, plot2, plot3, ncol = 1)

# Display the combined plot
print(combined_plot)
library(ggplot2)
library(ggdist)
library(tidyverse)
library(gridExtra)

# Read the first data file
data1 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/end_gene/R00_1_interleave_blast_bestmatch_filt.csv", header = FALSE)

# Read the second data file
data2 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/end_gene/R00_2_interleave_blast_bestmatch_filt.csv", header = FALSE)

# Read the third data file
data3 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/end_gene/R00_3_interleave_blast_bestmatch_filt.csv", header = FALSE)

# Assign colors to each data group
colors <- c("#FFCCCC", "#CCFFCC", "#CCCCFF")

# Function to create raincloud plot for a single data frame
create_raincloud_plot <- function(data, title, color) {
  # Create the raincloud plot
  ggplot(data, aes(x = factor(1), y = V2, fill = factor(1))) +
    stat_halfeye(
      adjust = 0.5,
      justification = -0.2,
      .width = 0,
      point_colour = NA
    ) +
    geom_boxplot(
      width = 0.12,
      outlier.color = NA,
      alpha = 0.5
    ) +
    stat_dots(
      side = "left",
      justification = 1.1,
      binwidth = 0.25
    ) +
    scale_fill_manual(values = color) +
    labs(
      title = ifelse(title == "", NULL, title),
      x = NULL,
      y = ifelse(title == "", NULL, "Porcentaje de identidad (%)"),
      fill = NULL
    ) +
    coord_flip() +
    scale_y_reverse(limits = c(100, 70)) +
    theme_bw() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      axis.text.y = element_text(margin = margin(r = 10)),
      axis.title.y = element_text(margin = margin(r = 20))
    )
}

# Create the raincloud plots for each data frame
plot1 <- create_raincloud_plot(data1, "Tiempo 1", colors[1])
plot2 <- create_raincloud_plot(data2, "Tiempo 2", colors[2])
plot3 <- create_raincloud_plot(data3, "Tiempo 3", colors[3])

# Adjust the width of plots 2 and 3 to match plot 1
plot2 <- plot2 + theme(plot.margin = margin(l = 0, r = 0.5, b = 0, t = 0))
plot3 <- plot3 + theme(plot.margin = margin(l = 0, r = 0.5, b = 0, t = 0))

# Combine the plots using arrangeGrob()
combined_plot <- gridExtra::arrangeGrob(plot1, plot2, plot3, ncol = 1)

ruta <- "/home/miguel/G3/Bioinformatics/mapping/New_approach/Alltimes_Endgene_raincloudplot.png"
png(filename = ruta, width = 1000, height = 800, units = "px")
print(combined_plot)
dev.off()


# Display the combined plot
print(combined_plot)


