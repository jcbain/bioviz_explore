library(r2d3)
library(readr)
library(dplyr)
library(tidyr)
library(purrr)
library(glue)

directory <- 'data/run20191024_180222/'
pat <- 'm1e-2_mu1e-6_r1e-6_sigsqr5'

fs_alleles <- list.files(path = directory, 
                         pattern = glue('{pat}_genome*'), 
                         full.names = T)

fullgenome <- read_delim(glue("{directory}{pat}_fullgenome.txt"), delim = ' ')

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

chrome <- alleles %>% filter(ind_id == 0 & pop == 0 & rep == 0 & output_gen == 50000)

r2d3(script = "supplementals/chrome_play.js", data = jsonlite::toJSON(chrome), viewer = 'browser')
