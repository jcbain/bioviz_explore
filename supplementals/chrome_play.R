library(r2d3)
library(readr)
library(dplyr)
library(tidyr)
library(purrr)

fs_alleles <- list.files(path = 'data/run20191022_174414/', 
                         pattern = 'm1e-2_mu1e-6_r1e-6_sigsqr5_genome*', 
                         full.names = T)

fullgenome <- read_delim("data/run20191022_174414/m1e-2_mu1e-6_r1e-6_sigsqr5_fullgenome.txt", delim = ' ')

alleles <- map(fs_alleles, 
               function(x){
                 read_delim(x, delim = ' ') %>% 
                   mutate(
                     rep = as.numeric(rep),
                     genome = paste0('genome', match(x, fs_alleles))
                   ) %>%
                   right_join(select(fullgenome, -genome)) %>%
                   complete(ind_id, pop, rep, output_gen, genome, 
                            nesting(position), 
                            fill = list(select_coef = 0)) %>% 
                   drop_na(ind_id, pop, rep, output_gen, genome)
               }) %>% 
  reduce(bind_rows)

chrome <- alleles %>% filter(ind_id == 0 & pop == 0 & rep == 0 & output_gen == 2500 & genome == 'genome1')

r2d3(script = "supplementals/chrome_play.js", data = jsonlite::toJSON(chrome))
