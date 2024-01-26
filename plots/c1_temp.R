library(Hmisc)
library(latex2exp)

m <- read.table(file = "c1_A_output_r-wind300_hd_8_time_100.txt", sep = ",", header = T)
#m <- read.table(file = "c1_B_output_r-wind100_hd_8_time_100.txt", sep = ",", header = T)

# Total power demand and supply
pdf(file = "c1_tmp_supply_demand.pdf", width = 8, height = 8)
par(mar=c(5,7.5,4,2)+.1) # 'bottom', 'left', 'top', 'right'
plot(m$tick, m$sumDemand/1000, type = "l", lty = 1, lwd = 3, col = "red", 
     xlab = "Time step [-]",
     ylab = "Total power demand and \n total power feed-in [TWh]",
     ylim = c(0, 30),
     yaxt='n',
     cex.lab = 2.5,
     cex.axis= 2.2
)
points(m$tick,m$sumFeedin/1000, type = "l", lty = 1, lwd = 2, col = "#969696")
minor.tick(nx = 2, ny = 2, tick.ratio = 0.5)
abline(v = 40, col = "black", lwd = 1.8, lty = 2)
legname <- c("Total power demand", "Total power feed-in")
legend('topright',legname, lty = 1, lwd = 4, col = c('red', '#969696'), bty = 'o', cex = 1.3, bg = "white", horiz = T)
axis(2, at = c(0, 5, 10, 15, 20, 25), labels = c(0, 5, 10, 15, 20, 25), cex.axis = 1.8)
title(TeX('$v_{wind} = 300$ MW / time step'), adj = 0.5, line = 1.0, cex.main=2.5)
mtext("(a)", side = 3, cex = 4, font = 2, line = 1, adj = -0.25)
dev.off()

# Power feed-in
pdf(file = "c1_tmp_feedin.pdf", width = 8, height = 8)
par(mar=c(5,7.5,4,2)+.1) # 'bottom', 'left', 'top', 'right'
plot(m$tick, m$supplyWind/1000, type = "l", col = "#0570b0", lwd = 3,
     xlab = "Time step [-]", 
     ylab = "Power feed-in [TWh]",
     ylim = c(0, 30),
     yaxt='n',
     cex.lab = 2.5,
     cex.axis= 2.2
)
points(m$tick, m$supplyPv/1000, type = "l", col = "#fc8d59", lwd = 3)
points(m$tick, m$supplyConv/1000, type = "l", col = "#525252", lwd = 3)
minor.tick(nx = 2, ny = 2, tick.ratio = 0.5)
abline(v = 40, col = "black", lwd = 1.8, lty = 2)
legname <- c("Wind", "Solar", "Conventionals")
legend('topright', legname, lty = 1, lwd = 4, col = c('#0570b0', '#fc8d59', '#525252'), bty = 'o', cex = 1.2, bg = "white", horiz = T)
axis(2, at = c(0, 5, 10, 15, 20, 25), labels = c(0, 5, 10, 15, 20, 25), cex.axis = 1.8)
title(TeX('$v_{wind} = 300$ MW / time step'), adj = 0.5, line = 1.0, cex.main=2.5)
mtext("(a)", side = 3, cex = 4, font = 2, line = 1, adj = -0.25)
dev.off()

# Number of power plants
pdf(file = "c1_tmp_number_renewables.pdf", width = 8, height = 8)
par(mar=c(5,7.5,4,2)+.1) # 'bottom', 'left', 'top', 'right'
plot(m$tick, m$numberWind, type = "l", col = "#0570b0", lwd = 3,
     xlab = "Time step [-]", 
     ylab = "Number of power plants [-]",
     ylim = c(0, 4500),
     yaxt='n',
     cex.lab = 2.5,
     cex.axis= 2.2
)
points(m$tick, m$numberPV, type = "l", col = "#fc8d59", lwd = 3)
minor.tick(nx = 2, ny = 2, tick.ratio = 0.5)
abline(v = 40, col = "black", lwd = 1.8, lty = 2)
legname <- c("Wind", "Solar")
legend('topright', legname, lty = 1, lwd = 4, col = c('#0570b0', '#fc8d59'), bty = 'o', cex = 1.3, bg = "white", horiz = T)
axis(2, at = c(0, 1000, 2000, 3000, 4000), labels = c(0, 1000, 2000, 3000, 4000), cex.axis = 1.8)
title(TeX('$v_{wind} = 300$ MW / time step'), adj = 0.5, line = 1.0, cex.main=2.5)
mtext("(a)", side = 3, cex = 4, font = 2, line = 1, adj = -0.25)
dev.off()
