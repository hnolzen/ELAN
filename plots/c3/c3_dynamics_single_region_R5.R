library(ggplot2)

m <- read.table(file = "output_R2_R5_D6_217_1000_final.txt", sep = ",", header = T)

cols <- c("Regional welfare" = "green4", "Number of wind power plants" = "gray10")

p1 <- ggplot(data = m, aes(x = tick)) + 
  geom_line(size = 0.6, aes(y = welfare5, colour = "Regional welfare")) +
  geom_line(size = 1.0, aes(y = wind5, colour = "Number of wind power plants")) + 
  geom_hline(yintercept = 0, linetype = "dashed", size = 0.75) +
  
  geom_vline(xintercept =  46, linetype = "solid", size = 0.4) +
  geom_vline(xintercept =  97, linetype = "solid", size = 0.4) +
  geom_vline(xintercept = 148, linetype = "solid", size = 0.4) +
  geom_vline(xintercept = 380, linetype = "solid", size = 0.4) +
  
  labs(x = "Time step [-]", 
       y = "Regional welfare [MU]", 
       color = "") + 
  coord_cartesian(ylim = c(-120, 160)) +
  scale_x_continuous(breaks = seq(0, 500, by = 50), limits = c(0, 500), expand = c(0, 0)) +
  scale_y_continuous(breaks = seq(-250, 150, by = 50),
                     sec.axis = sec_axis(~ . * 100/100, 
                     breaks = seq(-150, 150, by = 50),
                     name = "Number of wind power plants [-]")) +
  scale_color_manual(values = cols) +
  theme_classic() + 
  theme(plot.title = element_text(size = 18, face = "bold",  hjust = 0.5),
        plot.margin = unit(c(1.10, 0.70, 0.25, 0.25), "cm"),
        legend.background = element_rect(size = 0.1, linetype = "solid", colour = "black"),
        legend.key.size = unit(1, "line"),
        legend.text = element_text(size = 16),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.position = c(0.615, 0.925),
        axis.text = element_text(colour = "black", size = 16), 
        axis.title = element_text(colour = "black", size = 20),
        axis.title.y.right = element_text( angle = 90), 
        panel.grid.major.y = element_line(colour = "#e4e4e4", size = 0.1), 
        panel.grid.major.x = element_line(colour = "#e4e4e4", size = 0.1), 
        panel.border = element_rect(fill = NA, size = 0.75)) +
  annotate("text", x = 480, y = 150, label = "(a)", size = 12, fontface = 2) +
  guides(color = guide_legend(override.aes = list(linewidth = 3)))

ggsave(filename = "c3_single_region5.pdf", device = "pdf",
       width = 30, height = 11, units = "cm")
p1
dev.off()
