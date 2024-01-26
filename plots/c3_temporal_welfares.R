library(ggplot2)
library(grid)

m <- read.table(file = "output_A.txt", sep = ",", header = T)
#m <- read.table(file = "output_B.txt", sep = ",", header = T)
#m <- read.table(file = "output_C.txt", sep = ",", header = T)

cols <- c("R1" = "skyblue", "R2" = "steelblue3", "R3" = "plum3", 
          "R4" = "green3", "R5" = "green4", "R6" = "springgreen",
          "R7" = "gold2", "R8" = "orangered3", "R9" = "darkorange1")

p1 <- ggplot(data = m, aes(x = tick)) + 
        geom_line(size = 0.5, aes(y = welfare1, colour = "R1")) +
        geom_line(size = 0.5, aes(y = welfare2, colour = "R2")) +
        geom_line(size = 0.5, aes(y = welfare3, colour = "R3")) +
        geom_line(size = 0.5, aes(y = welfare4, colour = "R4")) +
        geom_line(size = 0.5, aes(y = welfare5, colour = "R5")) +
        geom_line(size = 0.5, aes(y = welfare6, colour = "R6")) +
        geom_line(size = 0.5, aes(y = welfare7, colour = "R7")) +
        geom_line(size = 0.5, aes(y = welfare8, colour = "R8")) +
        geom_line(size = 0.5, aes(y = welfare9, colour = "R9")) +
        geom_hline(yintercept = 0, linetype = "dashed", size = 0.8) +
        
        labs(x = "Time step [-]", 
             y = "Regional welfare [MU]", 
             color = "Regions:") + 
        coord_cartesian(ylim = c(-300, 1140)) +
        scale_x_continuous(breaks = seq(0, 500, by = 50), expand = c(0, 0), limits = c(0, 500)) +
        scale_y_continuous(breaks = seq(-400, 1140, by = 100), limits = c(-400, 1140)) +
        scale_color_manual(values = cols) +
        theme_classic() + 
        theme(plot.title = element_text(size = 20, face = "bold", hjust = - 0.05), 
              plot.margin = unit(c(0.25, 0.75, 0.25, 0.25), "cm"),
              legend.background = element_rect(size = 0.1, linetype = "solid", colour = "black"),
              legend.direction = "horizontal",
              legend.box = "horizontal", 
              legend.position = c(0.66, 0.94),
              axis.text = element_text(colour = "black", size = 16), 
              axis.title = element_text(colour = "black", size = 22),
              axis.line = element_line(size = 0.2),
              axis.ticks = element_line(colour = "black"), 
              panel.grid.major.y = element_line(colour = "#e4e4e4", size = 0.1), 
              panel.grid.major.x = element_line(colour = "#e4e4e4", size = 0.1),  
              panel.border = element_rect(fill = NA, size = 0.5)) +
        guides(color = guide_legend(nrow = 1, override.aes = list(linewidth = 7)))

ggsave(filename = "c3_tmp_regional-welfare_A.pdf", device = "pdf",
       width = 26, height = 14, units = "cm")

p1
dev.off()
