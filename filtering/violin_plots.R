library(ggplot2)

# Read the first data file
data1 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/HSVd/R00_1_interleave_blast_bestmatch_filt.csv", header = FALSE)

# Read the second data file
data2 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/HSVd/R00_2_interleave_blast_bestmatch_filt.csv", header = FALSE)

# Read the third data file
data3 <- read.csv("/home/miguel/G3/Bioinformatics/mapping/New_approach/HSVd/R00_3_interleave_blast_bestmatch_filt.csv", header = FALSE)

# Assign colors to each data group
colors <- c("#FFCCCC", "#CCFFCC", "#CCCCFF")

# Create a list with the data frames of the files
data_list <- list(data1, data2, data3)

# Get the length of each data file
lengths <- sapply(data_list, nrow)

# Create a vector with repeated label values based on the length of each file
repeated_labels <- rep(c("Tiempo 1", "Tiempo 2", "Tiempo 3"), times = lengths)

# Combine the data frames into a single data frame
combined_data <- do.call(rbind, data_list)

# Add the "Group" column to the combined data frame
combined_data$Group <- repeated_labels

# Create the violin plot
plot <- ggplot(combined_data, aes(x = Group, y = V2, fill = Group)) +
  geom_violin(trim = TRUE) +
  geom_boxplot(width = 0.1, fill = "white", color = "black", outlier.shape = NA) +
  labs(x = NULL, y = "Porcentaje de identidad (%)", fill = "Grupo") +
  scale_fill_manual(values = colors) +
  theme_bw()

# Save the plot in high resolution
ggsave("/home/miguel/G3/Bioinformatics/Figures/violin_plots_blast/alltimes_HSVd_violinplot.png", plot, dpi = 300)
