library(Hmisc)
library(latex2exp)

m <- read.table(file = "c1_tmp_mismatch_0.txt", sep = ",", header = T)
#m <- read.table(file = "c1_tmp_mismatch_50.txt", sep = ",", header = T)
#m <- read.table(file = "c1_tmp_mismatch_150.txt", sep = ",", header = T)
#m <- read.table(file = "c1_tmp_mismatch_300.txt", sep = ",", header = T)

pdf(file = "c1_mismatch_a.pdf", width = 6, height = 6)
par(mar=c(6,5,4,2)+.1) # 'bottom', 'left', 'top', 'right'
plot(m$tick, m$mismatchDegree, type = "l", col = "black", yaxt='n',  
     main = "",
     xlab = "Time step [-]", 
     ylab = "Coverage [%]",
     ylim = c(0, 120),
     cex.lab = 2.2,
     cex.axis = 1.6, 
     lwd = 3
)
abline(v = 40, col = "black", lwd = 1.8, lty = 2)
minor.tick(nx = 2, ny = 2, tick.ratio = 0.5)
axis(2, at = c(0, 20, 40, 60, 80, 100), labels = c(0, 20, 40, 60, 80, 100), par(cex.axis=1.6))
title(TeX('$v_{wind} = 0$ MW / time step'), adj = 0.5, line = 1.0, cex.main=2.0)
mtext("(a)", side = 3, cex = 3, font = 2, line = 1, adj = -0.2)
dev.off()
