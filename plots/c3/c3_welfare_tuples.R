library(ggplot2)

df <- read.table(file = "C3-point-308.csv", sep = ",", skip = 7)
df_market <- read.table(file = "C3-point-308-market.csv", sep = ",", skip = 7)

pd <- df[4:8]
colnames(pd) <- c("demand", "coverage", "welfare", "welfare_full", "fairness")

pd_market <- df_market[6:7]
colnames(pd_market) <- c("welfare_market", "welfare_full_market")

cbind(pd, pd_market)
pd[, c("welfare_market", "welfare_full_market")] <- pd_market

pd$efficiency <- pd$welfare_full - pd$welfare_full_market

pd$pointclass <- ifelse(pd$coverage < 97, 3, 
                        ifelse(pd$fairness == 1, 
                               ifelse(pd$efficiency < 0, 1, 0), 
                               ifelse(pd$efficiency < 0, 3, 2)))

legend_names <- c("secure, fair, more efficient", 
                  "secure, fair, equally or less efficient", 
                  "secure, unfair, more efficient", 
                  "insecure")
legend_color <- c('#7fbf7b', '#999999', '#f1a340', '#c51b7d')
colScale <- scale_colour_manual(name = "Constellation ID = 308", 
                                values = legend_color, 
                                labels = legend_names, drop = FALSE)

pointplot <- ggplot(data = pd, 
                    aes(x = demand, 
                        y = efficiency, 
                        colour = factor(pointclass, levels = c(0,1,2,3)))) + 
  geom_point(size = 3) +
  labs(x = "Household power demand [MWh]", y = "Efficiency [MU]") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  coord_cartesian(ylim = c(-500, 1750)) +
  scale_x_continuous(breaks = seq(1, 15, by = 1)) +
  scale_y_continuous(breaks = seq(-500, 1750, by = 250)) +
  colScale + 
  theme_classic() + 
  theme(plot.title = element_text(size = 18, face = "bold",  hjust = 0.5), 
        legend.background = element_rect(size = 0.1, linetype = "solid", colour = "black"),
        legend.key.size = unit(0.50, "cm"), 
        legend.direction = "vertical",
        legend.box = "vertical", 
        legend.position = c(0.81, 0.82),
        axis.text = element_text(colour = "black", size = 14), 
        axis.title = element_text(colour = "black", size = 16),
        axis.line = element_line(colour = "black", size = 0.3), 
        panel.grid.major.y = element_line(colour = "#e4e4e4", linewidth = 0.1), 
        panel.border = element_rect(fill = NA, linewidth = 0.1))

ggsave(filename = "c3_tuple_308.pdf", device = "pdf",
       width = 20, height = 12, units = "cm")

pointplot
dev.off()
