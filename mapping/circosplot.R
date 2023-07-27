

library(circlize)

df = data.frame(
  name  = "HSVd",
  start = 0,
  end   = 298)

TAB = data.frame(pos = 1:297)
files = list.files("/home/miguel/G3/Bioinformatics/pysamstats/pysamstats/sorted/circos_plot_data", pattern = ".csv")
for (file in files) {
  tab = read.csv(paste0("/home/miguel/G3/Bioinformatics/pysamstats/pysamstats/sorted/circos_plot_data/", file))
  time = unlist(strsplit(file, "_"))[2]
  rep = unlist(strsplit(unlist(strsplit(file, "_"))[3], ".", fixed = T))[1]
  if (nrow(tab) == 0) {
    tab = data.frame(pos = 1:297, ratio = NA)
    colnames(tab) = c("pos", paste0("ratio_", time, "_", rep))
  } 
  else {
    tab$"ratio" = tab$mismatches/tab$matches
    tab = tab[,c("pos", "ratio")]
    colnames(tab) = c("pos", paste0("ratio_", time, "_", rep))
  }
  TAB = merge(TAB, tab, by = "pos", all = T)
}

T1 <- list()
T2 <- list()
T3 <- list()
for (i in 1:nrow(TAB)) {
  nombre_lista <- TAB[i, 1]
  
  valores_lista_T1 <- c(TAB[i, 3], TAB[i, 4])
  valores_lista_T2 <- c(TAB[i, 5], TAB[i, 6], TAB[i, 7])
  valores_lista_T3 <- c(TAB[i, 8], TAB[i, 9], TAB[i, 10])
  
  # Agregamos la lista completa a la lista principal
  T1[[nombre_lista]] <- valores_lista_T1
  T2[[nombre_lista]] <- valores_lista_T2
  T3[[nombre_lista]] <- valores_lista_T3
}


png(filename = "/home/miguel/G3/Bioinformatics/pysamstats/pysamstats/sorted/circos_plot_data/Plot5.png", height = 8000, width = 8000, res = 800)
circos.genomicInitialize(df, plotType = NULL)

circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
  chr = CELL_META$sector.index
  xlim = CELL_META$xlim
  ylim = CELL_META$ylim
  circos.axis(h = 1, major.at = seq(0, xlim[2] + 5, 5), labels = as.character(seq(0, xlim[2] + 5, 5)), labels.cex = 0.8)
  circos.rect(xlim[1], 0, xlim[2], 1, col = "#000000B3")
  circos.text(mean(xlim), mean(ylim), "", cex = 0.5, col = "black", facing = "inside", niceFacing = TRUE, font = 2)
}, bg.border = NA, track.height = 0.05)

circos.track(ylim = c(0, 0.015), panel.fun = function(x, y) {
  value = T2
  circos.boxplot(value, 1:297, col = "white", lwd = 1)
}, track.height = 0.2)
circos.track(ylim = c(0, 0.015), panel.fun = function(x, y) {
  value = T3
  circos.boxplot(value, 1:297, col = "white", lwd = 1)
}, track.height = 0.2)
circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
  value = T1
  circos.boxplot(value, 1:297, col = "white", lwd = 1)
}, track.height = 0.2)

draw.sector(36, -39, rou1 = 0.95, rou2 = 0.28, clock.wise = T, col = "#FFB6C180") # Dominio TL (Rosa claro transparente)
draw.sector(-39, -75, rou1 = 0.95, rou2 = 0.28, clock.wise = T, col = "#80808080") # Dominio P (Gris claro transparente)
draw.sector(-287, -324, rou1 = 0.95, rou2 = 0.28, clock.wise = T, col = "#80808080") # Dominio P (Gris claro transparente)
draw.sector(-75, -118, rou1 = 0.95, rou2 = 0.28, clock.wise = T, col = "#FFD70080") # Dominio C (Amarillo oro transparente)
draw.sector(-243, -287, rou1 = 0.95, rou2 = 0.28, clock.wise = T, col = "#FFD70080") # Dominio C (Amarillo oro transparente)
draw.sector(-118, -146, rou1 = 0.95, rou2 = 0.28, clock.wise = T, col = "#66CDAA80") # Dominio V (Turquesa claro transparente)
draw.sector(-218, -243, rou1 = 0.95, rou2 = 0.28, clock.wise = T, col = "#66CDAA80") # Dominio V (Turquesa claro transparente)
draw.sector(-146, -218, rou1 = 0.95, rou2 = 0.28, clock.wise = T, col = "#FFA07A80") # Dominio TR (Salmón claro transparente)


circos.clear()

invisible(dev.off())


