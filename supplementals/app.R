library(shiny)
library(ggplot2)
library(purrr)
library(readr)
library(dplyr)
library(magrittr)
library(stringr)


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

files <- list.files("./data/run20190930_154212/", full.names = TRUE)
# init_file <- read_lines("../descartes/local_adaptation.slim")
# relevant_locs <- map(init_file, function(x){
#   str_detect(x, '\tinitializeGenomicElement\\(g1,')
# }) %>% 
#   reduce(c)
# 
# all_positions <- map(init_file[relevant_locs], function(x){
#   old <- str_remove(x, '\tinitializeGenomicElement\\(g1,')
#   str_extract_all(old, '(\\d)+')[[1]]
# }) %>%
#   reduce(c) %>% as.numeric()
# 
# all_bases <- tibble(position = all_positions)

df <- map(files, function(x){
  read_delim(file = x, delim = " ") 
  }) %>% 
  reduce(bind_rows) %>% 
  normalize_cols(col = p1_freq) %>%
  normalize_cols(col = p2_freq)

# ndf <- df %>%
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, output_gen, rep) %>%
#   group_split() %>% 
#   map(function(x){
#     migr <- x %>% summarize_to_val(migr_rate) 
#     mut <- x %>% summarize_to_val(mut_rate) 
#     recomb <- x %>% summarize_to_val(recomb_rate) 
#     fitness <- x %>% summarize_to_val(fitness_width)
#     output <- x %>% summarize_to_val(output_gen)
#     replicate <- x %>% summarize_to_val(rep)
#     
#     x %>% right_join(all_bases) %>%
#       tidyr::replace_na(list(migr_rate = migr, mut_rate = mut, 
#                              recomb_rate = recomb, fitness_width = fitness, 
#                              output_gen = output, rep = replicate, 
#                              select_coef = 0, p1_freq = 0, 
#                              p2_freq = 0)) 
#   }) %>%
#   reduce(bind_rows)
  
# df <- ndf %>% 
df <- df %>%
  mutate(p1_rel = p1_freq * select_coef, p2_rel = p2_freq * select_coef) %>%
  group_by(migr_rate, mut_rate, recomb_rate, fitness_width, rep) %>%
  mutate(param_group = group_indices()) %>% ungroup() %>%
  mutate(diff = p1_rel - p2_rel)
  # ggplot() +
  # geom_tile(aes(x = factor(output_gen), y = factor(position), color = diff, fill = diff)) +
  # coord_fixed() +
  # scale_fill_gradientn(colours = c('#6e5400', '#ebe834', '#2abdb5'), values = c(-1, 0, 1)) +
  # scale_colour_gradientn(colours = c('#6e5400', '#ebe834', '#2abdb5'), values = c(-1, 0, 1))
# 
# df <- df %>%
#   mutate(p1_rel = p1_freq * select_coef, p2_rel = p2_freq * select_coef) %>%
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width, output_gen, rep) %>%
#   summarize(p1_mean = sum(p1_rel), p2_mean = sum(p2_rel)) %>% 
#   mutate(p_diff = p1_mean - p2_mean) %>% 
#   ungroup() %>% 
#   group_by(migr_rate, mut_rate, recomb_rate, fitness_width) %>% 
#   mutate(group_param = group_indices())

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
  
  dat <- reactive({
    df %>% filter(migr_rate == input$migr & 
                    fitness_width == input$fit & 
                    recomb_rate == input$recom & 
                    rep == input$rep)
  })
  
  anti_dat_grouped <- reactive({
    df %>% 
      filter(param_group != (dat() %>% select(param_group) %>% pull())[1]) %>%
      filter(rep == input$rep) %>%
      group_by(migr_rate, fitness_width, recomb_rate, rep, output_gen, param_group) %>%
      summarize(mean_p1 = sum(p1_rel), mean_p2 = sum(p2_rel))
  })
  
  grouped_dat <- reactive({
    dat() %>% group_by(migr_rate, fitness_width, recomb_rate, rep, output_gen, param_group) %>% 
      summarize(mean_p1 = sum(p1_rel), mean_p2 = sum(p2_rel))
  })
  
  # reactive_val <- reactive({
  #   (df %>% filter(migr_rate == input$migr & fitness_width == input$fit & recomb_rate == input$recom & rep == input$rep) %>%
  #     ungroup() %>% group_by(group_param) %>% pull())[1]
  # })
  # 
  # anti_dat <- reactive({
  #   df %>% filter(group_param != reactive_val()) 
  # })
  # 
  # reactive_unvals <- reactive({anti_dat() %>% group_by(group_param) %>% summarize() %>% pull()})
  # 
  # desc_frame <- reactive({
  #   anti_dat() %>% mutate(desc = glue::glue("m={migr_rate}, r={recomb_rate}, fit={fitness_width}")) %>% 
  #     group_by(group_param, desc) %>% summarize()
  # })
  # 
  # anti_dat2 <- reactive({
  #   anti_dat() %>% 
  #     right_join(desc_frame())
  # })
  
  # highlight_dat <- reactive({
  #   map(reactive_unvals(), function(x){
  #     dat() %>% mutate(group_param = x)
  #   }) %>% reduce(bind_rows) %>% right_join(desc_frame())
  # })
  #   
  
  output$plot <- renderPlot({
    ggplot(data = dat()) +
      geom_tile(aes(y = factor(output_gen), x = factor(position), 
                    color = diff, fill = diff)) + 
      coord_fixed() +
      scale_fill_gradientn(colours = c('#6e5400', '#ebe834', '#2abdb5'), values = c(-1, 0, 1),
                           na.value = '#ebe834') +
      scale_colour_gradientn(colours = c('#6e5400', '#ebe834', '#2abdb5'), values = c(-1, 0, 1),
                             na.value = '#ebe834') +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 90, hjust = 1),
              axis.text = element_text(size = 8)) +
      labs(x = 'position', y = 'generation')
      
  })
  
  output$plot2 <- renderPlot({
    ggplot() + 
      geom_line(data = anti_dat_grouped(), 
                aes(x = output_gen, y = mean_p1, group = factor(param_group)), alpha = .7) +
      geom_line(data = grouped_dat(),  aes(x = output_gen, y = mean_p1), color = '#2abdb5', size = 2) +
      theme_bw()
    
  })
  
  output$plot3 <- renderPlot({
    ggplot() + 
      geom_line(data = anti_dat_grouped(), 
                aes(x = output_gen, y = mean_p2, group = factor(param_group)), alpha = .7) +
      geom_line(data = grouped_dat(),  aes(x = output_gen, y = mean_p2), color = '#ebe834', size = 2) +
      theme_bw()
    
  })
  # output$plot <- renderPlot({
  #   ggplot(data = anti_dat2()) + 
  #     geom_line(aes(x = output_gen, y = p1_mean, group = factor(rep)), alpha = .5) +
  #     geom_line(data = highlight_dat(), aes(x = output_gen, y = p1_mean), color = "blue") +
  #     facet_wrap(~factor(desc)) +
  #     theme_bw() +
  #     theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  #     labs(y = "Population 1")
  # })
  # 
  # output$plot2 <- renderPlot({
  #   ggplot(data = anti_dat2()) + 
  #     geom_line(aes(x = output_gen, y = p2_mean, group = factor(rep)), alpha = .5) +
  #     geom_line(data = highlight_dat(), aes(x = output_gen, y = p2_mean), color = "orange") +
  #     facet_wrap(~factor(desc)) +
  #     theme_bw() + 
  #     theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  #     labs(y = "Population 2")
  # })
  # 
  # output$plot3 <- renderPlot({
  #   ggplot(data = anti_dat2()) + 
  #     geom_line(aes(x = output_gen, y = p_diff, group = factor(rep)), alpha = .5) +
  #     geom_line(data = highlight_dat(), aes(x = output_gen, y = p_diff), color = "green") +
  #     facet_wrap(~factor(desc)) +
  #     theme_bw() + 
  #     theme(axis.text.x = element_text(angle = 90, hjust = 1)) 
  # })
  # 
}

shinyApp(ui, server)
