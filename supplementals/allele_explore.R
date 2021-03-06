library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(ggplot2)

# read in selected files
fs_alleles <- list.files(path = 'data/run20191203_180926', 
                         pattern = '*[^full]genome*', 
                         full.names = T)

# retun only odd from a vector indexes
odd <- function(x) x%%2 != 0
even <- function(x) x%%2 == 0

#' create function create new columns from param values
#' 
#' From a vector of namees, map values to a data frame from a same length
#' vector of values.
#' 
#' @param data The dataset to have the columns added to.
#' @param names Vector of column names.
#' @param vals Vector of values to occupy the new columns. Must be of same
#'   length as `names`.
#' 
#' @return Data frame with new columns.
multi_mutate <- function(data, names, vals){
  purrr::map(1:length(names), function(x){
    dplyr::transmute(data, !!names[x] := vals[x])
  }) %>% reduce(dplyr::bind_cols) %>% dplyr::bind_cols(data)

}

alleles <- map(fs_alleles, 
               function(x){
                 string_to_parse <- str_remove(x, "_genome\\d.txt")
                 string_to_parse <- str_remove(string_to_parse, "data/run\\d+_\\d+/")
                 params <- map(
                   str_split(string_to_parse, "_")[[1]],
                   function(v){
                     str_split(v, "(?<=[a-zA-Z])\\s*(?=[0-9])")
                   }
                 )
                 params <- unlist(params)
                 param_names <- params[odd(1:length(params))]
                 param_vals <- params[even(1:length(params))]
                 read_delim(x, delim = ' ') %>% 
                   mutate(
                     rep = as.numeric(rep),
                     genome = paste0('genome', match(x, fs_alleles))
                   ) %>% multi_mutate(param_names, param_vals) 
                 }) %>% 
  reduce(bind_rows) 


phenotype <- read_delim("data/run20191022_174414/m1e-2_mu1e-6_r1e-6_sigsqr5_phenotypes.txt", delim = ' ')
mutation <- read_delim("data/run20191022_174414/m1e-2_mu1e-6_r1e-6_sigsqr5_mutations.txt", delim = ' ')
fullgenome <- read_delim("data/run20191022_174414/m1e-2_mu1e-6_r1e-6_sigsqr5_fullgenome.txt", delim = ' ')

# pick the rep
rep_selection <- 0

alleles <- alleles %>% filter(rep == rep_selection)
phenotype <- phenotype %>% filter(rep == rep_selection)
mutation <- mutation %>% filter(rep == rep_selection)

# Test it out to see if allele mutation matches mutation
allele_mutation <- alleles %>% group_by(output_gen, position, pop, m, mu, r, sigsqr) %>% summarize(freq = n()/2000)







