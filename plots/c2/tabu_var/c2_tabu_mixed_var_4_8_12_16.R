library(ggplot2)
library(latex2exp)

df <- read.table(file = "C2-tabu-mixed.csv", sep = ",", skip = 7)
df6 <- read.table(file = "C2-tabu-mixed-600.csv", sep = ",", skip = 7)

colnames(df) <- c("run", "demand", "tabu", "step", "area_start", "area_end", "disutility", "security")
df$security2 <- ifelse(df$security < 98, "insecure", "secure") 
df$linie <- as.factor(1)

colnames(df6) <- c("run", "demand", "tabu", "step", "area_start", "area_end", "disutility", "security")
df6$security2 <- ifelse(df6$security < 98, "insecure", "secure") 
df6$linie <- as.factor(2)

df <- subset(df, demand == 4 & tabu > 0)
df6 <- subset(df6, demand == 4 & tabu > 0)

#df <- subset(df, demand == 8 & tabu > 0)
#df6 <- subset(df6, demand == 8 & tabu > 0)

#df <- subset(df, demand == 12 & tabu > 0)
#df6 <- subset(df6, demand == 12 & tabu > 0)

#df <- subset(df, demand == 16 & tabu > 0)
#df6 <- subset(df6, demand == 16 & tabu > 0)

p3 <- ggplot(data = df, aes(x = df$tabu, y = df$disutility)) + 
  geom_point(size = 5, aes(shape = as.factor(df$security2))) +
  geom_line(size = 1.5, aes(linetype = df$linie)) +
  geom_point(data = df6, size = 5, aes(x = df6$tabu, y = df6$disutility, shape = as.factor(df6$security2))) +
  geom_line(data = df6, size = 1.5, linetype = 2, aes(x = df6$tabu, y = df6$disutility, linetype = df6$linie)) +  
  ggtitle("Mixed distribution") + 
  labs(x = "", 
       y = "", 
       shape = "",
       linetype = "") +
  coord_cartesian(ylim = c(0, 6100)) +
  scale_x_continuous(breaks = seq(2, 12, by = 2)) +
  scale_y_continuous(breaks = seq(0, 6000, by = 1000)) +
  scale_shape_manual(values = c(15, 19),
                     limits = c("insecure", "secure")) +
  scale_linetype_manual(values = c(1, 3),
                        limits = c(1, 2),
                        labels = c(expression(paste(v[wind], " = 300")), 
                                   expression(paste(v[wind], " = 600")))) +
  theme_classic() + 
  theme(plot.title = element_text(size = 40,  hjust = 0.5, face = "bold"),
        legend.background = element_rect(size = 0.1, linetype = "solid", colour = "grey"),
        legend.key.size = unit(0.50, "cm"), 
        legend.direction = "horizontal",
        legend.box = "horizontal", 
        legend.position = c(0.50, 0.94), 
        axis.text = element_text(colour = "black", size = 24), 
        axis.title = element_text(colour = "black", size = 32),
        axis.title.y = element_blank(),
        panel.grid.major.y = element_line(colour = "#e4e4e4", linewidth = 0.1),
        panel.grid.minor.y = element_line(colour = "#e4e4e4", linewidth = 0.1),
        panel.border = element_rect(fill = NA, size = 1)) +
  annotate("text", x = 11.55, y = 6050, label = "(e)", size = 12, fontface = 2) + 
  annotate(geom="label", x = 7, y = 6025, label = TeX('$d_{h} = 4'), size = 12, fill = "white") +
  guides(shape = FALSE, linetype = FALSE)

ggsave(filename = "c2_tabu_mixed_var.pdf", device = "pdf",
       width = 15, height = 15, units = "cm")

p3
dev.off()
