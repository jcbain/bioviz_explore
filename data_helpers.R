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
                   ) 
               }) %>% 
  reduce(bind_rows)