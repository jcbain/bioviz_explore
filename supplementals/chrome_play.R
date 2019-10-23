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
                   ) 
               }) %>% 
  reduce(bind_rows)



r2d3(script = "supplementals/chrome_play.js", data = jsonlite::toJSON(fullgenome))
