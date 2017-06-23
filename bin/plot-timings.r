#!/usr/bin/env Rscript

library(RColorBrewer)
library(reshape2)
library(ggplot2)

df.control <- read.table("data/control-benchmark.dat", sep="\t", header=TRUE)
df.alternative <- read.table("data/alternative-benchmark.dat", sep="\t", header=TRUE)
trials <- 10

names(df.control) <- c("Variants", paste('Trial', seq(1,trials), sep=""))
names(df.alternative) <- c("Variants", paste('Trial', seq(1,trials), sep=""))

df.control$Code <- 'original-code'
df.alternative$Code <- 'missingness-feature'

df <- rbind(df.control, df.alternative)
df$Variants <- as.factor(df$Variants)

df.melted <- melt(df, id.vars = c('Variants', 'Code'))

p <- ggplot(df.melted, aes(x=Variants, y=value)) +
     geom_boxplot() +
     facet_wrap( ~ Code)
     
#theme(text=element_text(size=16, family="Helvetica"))

# linear scale boxplot
p <- ggplot(df.melted, aes(x=Variants, y=value, fill=Code)) + 
     theme(text=element_text(family="FranklinGothic-Book")) +
     scale_y_continuous(limits=c(0,20)) +
     geom_boxplot(lwd=0.2) + 
     scale_fill_brewer(palette="Set1") +
     ylab('Execution Time (seconds)') +
     ggtitle(sprintf("Benchmarking Execution Times"),
             subtitle=sprintf("# of Trials per Variant Set: %d", trials))
ggsave('data/benchmark.png')
     
# log10 scale boxplot
p <- ggplot(df.melted, aes(x=Variants, y=value, fill=Code)) + 
     theme(text=element_text(family="FranklinGothic-Book")) +
     geom_boxplot(lwd=0.2) + 
     scale_fill_brewer(palette="Set1") +
     scale_y_continuous(trans='log10', limits=c(0.01,20)) +
     ylab('log10(Execution Time in seconds)') +
     ggtitle(sprintf("Benchmarking Execution Times (Log-Scale)"),
             subtitle=sprintf("# of Trials per Variant Set: %d", trials))
ggsave('data/benchmark-log-scale.png')

#p <- ggplot(df.melted, aes(x=Variants, y=value, color=Code)) + geom_jitter(width = 0.2) + scale_fill_brewer(palette="Greens") + ylab("run time (secs)")
     
