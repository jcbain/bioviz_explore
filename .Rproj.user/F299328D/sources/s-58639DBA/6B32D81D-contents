library(readr)
library(dplyr)
library(purrr)
library(ggplot2)

fs_alleles <- list.files(path = 'data/run20191022_174414/', 
                         pattern = 'm1e-2_mu1e-6_r1e-6_sigsqr5_genome*', 
                         full.names = T)


alleles <- map(fs_alleles, 
               function(x){
                 read_delim(x, delim = ' ') %>% 
                   mutate(
                     rep = as.numeric(rep),
                     genome = paste0('genome', match(x, fs_alleles))
                   )
                 }) %>% 
  reduce(bind_rows)

phenotype <- read_delim("data/run20191022_174414/m1e-2_mu1e-6_r1e-6_sigsqr5_phenotypes.txt", delim = ' ')
mutation <- read_delim("data/run20191022_174414/m1e-2_mu1e-6_r1e-6_sigsqr5_mutations.txt", delim = ' ')
fullgenome <- read_delim("data/run20191022_174414/m1e-2_mu1e-6_r1e-6_sigsqr5_fullgenome.txt", delim = ' ')

alleles %>% group_by(pop, position, output_gen, rep) %>% summarize(sum(select_coef)) %>% filter(position == 4310001)

alleles %>% filter(position == 800001 & pop == 0 & output_gen == 2500 & rep == 0)
