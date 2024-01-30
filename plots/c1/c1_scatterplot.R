library(lattice)
library(latticeExtra)
library(grid)
library(gridExtra)
library(here)
library(scatterplot3d)
library(latex2exp)
source("addgrids3d.R")

df <- read.table(file = "c1-mwc-olr-sd-20-tr-2-hd-4_A.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-20-tr-2-hd-6_B.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-40-tr-2-hd-4_C.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-40-tr-2-hd-6_D.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-60-tr-2-hd-4_E.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-60-tr-2-hd-6_F.csv", sep = ",", header = T, skip = 6)

# Convert to Mio. MU
df$total.transition.costs <- round(df$total.transition.costs / 1000000, 2)

df$pcolor[df$mismatch.type == 0] <- '#a1d99b'
df$pcolor[df$mismatch.type == 1] <- '#fce997'
df$pcolor[df$mismatch.type == 2] <- '#b4b8b8'
pdf(file = "c1_scatter_a.pdf", width = 9, height = 8)
scatterplot3d(df$operating.life.renewables, 
              df$max.wind.cap, 
              df$total.transition.costs, 
              color = df$pcolor, 
              pch = 19,
              xlab = "Operating life renewables [time steps]", 
              ylab = "",
              zlab = "Total transition costs [Mio. MU]",
              cex.lab = 1.75,
              cex.axis = 1.6,
              cex.symbols = 1.67
)
addgrids3d(df$operating.life.renewables, 
           df$max.wind.cap, 
           df$total.transition.costs, grid = c("xy", "xz", "yz"))
text(x = 8, y = 0.97, "Wind power expansion \n per time step [MW]", cex = 1.7, srt = 40)
text(x = 0.25, y = 7.2, "(a)", cex = 4.5, font = 2)
mtext(TeX('$d_{h} = 4$, $t_{s} = 20'), side = 3, cex = 2.2, font=1)
dev.off()
