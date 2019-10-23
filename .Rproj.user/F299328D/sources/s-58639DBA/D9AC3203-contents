library(shiny)
library(ggplot2)
library(purrr)
library(readr)
library(dplyr)
library(magrittr)
library(stringr)
library(tidyr)
library(RColorBrewer)

# helper functions
normalize_cols <- function(data, col, thresh = 1, denom = 2000){
  col <- rlang::enquo(col) 
  col_name <- rlang::quo_name(col)
  if (any(data %>% select(!! col) %>% pull() > thresh)){
    data %>%
      mutate(!!col_name := !!col / denom)
  } else {
    data
  }
}

summarize_to_val <- function(data, col) {
  col <- rlang::enquo(col)
  
  data %>% group_by(!!col) %>% summarize() %>% pull()
}

files <- list.files("./data/run20190923_154315/", full.names = TRUE)

df <- map(files, function(x){
  read_delim(file = x, delim = " ") 
}) %>% 
  reduce(bind_rows) %>% 
  normalize_cols(col = p1_freq) %>%
  normalize_cols(col = p2_freq) %>%
  mutate(p1_mut = p1_freq * select_coef, p2_mut = p2_freq * select_coef) %>%
  group_by(migr_rate, mut_rate, recomb_rate, fitness_width, rep) %>% 
  mutate(param_group_rep = group_indices()) %>%
  ungroup() %>%
  group_by(migr_rate, mut_rate, recomb_rate, fitness_width) %>% 
  mutate(param_group = group_indices()) %>%
  ungroup() %>%
  mutate(allele_diff = p1_mut - p2_mut)

group_df <- df %>%
    group_by(migr_rate, mut_rate, recomb_rate, fitness_width, rep, param_group_rep, param_group, output_gen) %>%
    summarize(diff = sum(allele_diff)) %>%
    ungroup()
  

my_palette <- colorRampPalette(rev(brewer.pal(11, "Spectral")))
sc <- scale_colour_gradientn(colours = my_palette(100), limits=c(min(df$allele_diff), max(df$allele_diff)))
sf <- scale_fill_gradientn(colours = my_palette(100), limits=c(min(df$allele_diff), max(df$allele_diff)))


# df %>% filter(param_group_rep == 25) %>%  complete(output_gen, position, fill = list(allele_diff = 0)) %>%
#   ggplot(aes(x = factor(output_gen), y = factor(position), color = allele_diff, fill = allele_diff)) + 
#   geom_tile() + sc + sf

ui <- fluidPage(
  titlePanel("Simulation Explore"),
  sidebarPanel(width = 3,
               selectInput("migr", "migration rate: ", choices = df %>% group_by(migr_rate) %>% summarize()),
               selectInput("fit", "fitness width: ", choices = df %>% group_by(fitness_width) %>% summarize()),
               selectInput("recom", "recomb rate: ", choices = df %>% group_by(recomb_rate) %>% summarize()),
               selectInput("rep", "replicate: ", choices = df %>% group_by(rep) %>% summarize())
  ),
  mainPanel(plotOutput("plot"),
            plotOutput("plot2"), 
            plotOutput("plot3"))
)

server <- function(input, output){
  allele_diff_selection <- reactive({
    df %>% 
      filter(migr_rate == input$migr & 
             fitness_width == input$fit & 
             recomb_rate == input$recom & 
             rep == input$rep) %>%  
      complete(output_gen, position, fill = list(allele_diff = 0))
  })
  
  run_selection <- reactive({
    group_df %>%
      filter(migr_rate == input$migr & 
               fitness_width == input$fit & 
               recomb_rate == input$recom & 
               rep == input$rep)
  })
  
  selected_param_group <- reactive({
    (run_selection() %>% pull(param_group))[1]
  })
  
  output$plot <- renderPlot({
    ggplot(data = allele_diff_selection()) +
      geom_tile(aes(x = factor(output_gen), y = factor(position), 
                    fill = allele_diff), color = "white") + 
      sf +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1),
            axis.text = element_text(size = 8)) +
      labs(x = 'generation', y = 'position')
    
  })
  
  output$plot2 <- renderPlot({
    ggplot() +
      geom_line(data = group_df, aes(x = output_gen, y = diff, group = param_group_rep), alpha = .5) +
      geom_line(data = group_df %>% filter(param_group == selected_param_group()), aes(
        x = output_gen, y = diff, group = param_group_rep
      ), color = "orange") +
      geom_line(data = run_selection(), aes(output_gen, y = diff), color = 'green', size = 2) + 
      theme_bw()
  })
}

shinyApp(ui, server)


## EXPLORE UNCOMMENT TO SEE WHAT HAPPENS... IF YOU DARE
# df <- df %>%
#   mutate(p1_rel = p1_freq * select_coef, p2_rel = p2_freq * select_coef) %>%
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, rep) %>%
#   mutate(param_group = group_indices()) %>% ungroup() %>%
#   mutate(diff = p1_rel - p2_rel)
# 
# df %>% 
#   mutate(p1 = p1_freq * select_coef, p2 = p2_freq * select_coef) %>% 
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, output_gen, rep) %>% 
#   summarize(rel_p1 = sum(p1), rel_p2 = sum(p2)) %>% 
#   mutate(diff = rel_p1 - rel_p2) %>% ungroup() %>%filter(diff == max(diff))
# 
# df %>% 
#   mutate(p1 = p1_freq * select_coef, p2 = p2_freq * select_coef) %>% 
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, output_gen, rep) %>% 
#   mutate(param_group = group_indices()) %>%
#   summarize(rel_p1 = sum(p1), rel_p2 = sum(p2)) %>% 
#   mutate(diff = rel_p1 - rel_p2) %>% ungroup() %>%
#   filter(migr_rate == 0.00001 & mut_rate == 0.000001 & recomb_rate == 0.00000001 & fitness_width == 25 & rep == 3) %>%
#   ggplot(aes(x = output_gen, y = diff)) + geom_line()
# 
# 
# ndf <- df %>% 
#   mutate(p1 = p1_freq * select_coef, p2 = p2_freq * select_coef) %>% 
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, output_gen, rep) %>% 
#   summarize(rel_p1 = sum(p1), rel_p2 = sum(p2)) %>% 
#   mutate(diff = rel_p1 - rel_p2) %>%
#   ungroup() %>% 
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, rep) %>% 
#   mutate(param_group_rep = group_indices()) %>%
#   ungroup() %>%
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width) %>% 
#   mutate(param_group = group_indices()) %>%
#   ungroup()
# 
# mdf <- ndf %>%
#   filter(param_group_rep == 14)
# 
# ggplot() +
#   geom_line(data = ndf, aes(x = output_gen, y = diff, group = param_group_rep, color = factor(param_group))) +
#   geom_line(data = mdf, aes(x = output_gen, y = diff), color = "green", size = 2)
# 
# df %>% 
#   mutate(p1 = p1_freq * select_coef, p2 = p2_freq * select_coef) %>% 
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, rep) %>% 
#   mutate(param_group_rep = group_indices()) %>%
#   ungroup() %>%
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width) %>% 
#   mutate(param_group = group_indices()) %>%
#   ungroup() %>%
#   mutate(allele_diff = p1 - p2) %>%
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, rep, param_group_rep, param_group, output_gen) %>%
#   summarize(diff = sum(allele_diff)) %>% 
#   ungroup() %>% filter(diff == max(diff)) %>% View()
#   
