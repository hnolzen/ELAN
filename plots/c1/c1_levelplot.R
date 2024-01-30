library(lattice)
library(latticeExtra)
library(grid)
library(gridExtra)
library(scatterplot3d)
library(latex2exp)

df <- read.table(file = "c1-mwc-olr-sd-20-tr-2-hd-4_A.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-20-tr-2-hd-6_B.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-40-tr-2-hd-4_C.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-40-tr-2-hd-6_D.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-60-tr-2-hd-4_E.csv", sep = ",", header = T, skip = 6)
#df <- read.table(file = "c1-mwc-olr-sd-60-tr-2-hd-6_F.csv", sep = ",", header = T, skip = 6)

colors <- colorRampPalette(c('#addd8e','#ffeda0','#f0f0f0'))(256) 

pdf(file = "c1_level_a.pdf", width = 6, height = 5.2)
levelplot(mismatch.type~operating.life.renewables*max.wind.cap, 
          data = df, aspect = 0.8, col.regions = colors,
          main = list(label = TeX('$d_{h} = 4$, $t_{s} = 20$'), cex = 1.5),
          xlab = list(label = "Operating life renewables [time steps]", cex = 1.5), 
          ylab = list(label = "Wind power expansion per time step [MW]", cex = 1.3),
          scales = list(tck=c(1,0), x=list(cex=1.3), y=list(cex=1.3)),
          colorkey = FALSE,
          par.settings=list(par.main.text = list(y=grid::unit(-4, "mm"), 
                                                 x=grid::unit(8.6, "cm")))
)
grid.text(c("(a)"), x=0.18, y=0.97, vjust=1, hjust=0, gp=gpar(fontface=2, fontsize=28))
dev.off()
