library(shiny)
library(ggplot2)
library(purrr)
library(readr)
library(dplyr)
library(stringr)

files <- list.files("./data/run20190930_154212/", full.names = TRUE)


init_file <- read_lines("../descartes/local_adaptation.slim")
relevant_locs <- map(init_file, function(x){
  str_detect(x, '\tinitializeGenomicElement\\(g1,')
}) %>% 
  reduce(c)

all_positions <- map(init_file[relevant_locs], function(x){
  old <- str_remove(x, '\tinitializeGenomicElement\\(g1,')
  str_extract_all(old, '(\\d)+')[[1]]
}) %>%
  reduce(c) %>% as.numeric()

tibble(position = all_positions) %>% left_join(df %>% head()) %>% View()


df <- map(files, function(x){
  read_delim(file = x, delim = " ") 
}) %>% reduce(bind_rows)

mdf <- df %>% 
  group_by(migr_rate, mut_rate, recomb_rate, fitness_width) %>% 
  mutate(group_param = group_indices()) %>% 
  ungroup() %>%
  rename(p1_count = p1_freq, p2_count = p2_freq) %>%
  mutate(p1_freq = p1_count/2000, p2_freq = p2_count/2000) %>%
  mutate(p1_val = p1_freq * select_coef, p2_val = p2_freq * select_coef) %>%
  group_by(position, group_param, rep, output_gen) %>%
  summarize(p1_sum = sum(p1_val), p2_sum = sum(p2_val)) %>%
  mutate(diff = p1_sum - p2_sum)


ggplot(data = filter(mdf, group_param == 1 & rep == 1)) + 
  geom_tile(aes(x = factor(output_gen), y = factor(position), fill = diff)) +
  theme_minimal() +
  coord_fixed() +
  scale_fill_gradient2(low = '#f57067', high = '#7df75e', mid = '#ffffff') 

df <- readr::read_delim("~/Desktop/1_species1_outputPhenEnv.txt", delim = ' ')
