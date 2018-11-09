library(shiny)
library(ggplot2)

load("motifs.RData")

shinyServer(function(input, output) {
  
  chosen_motif_r <- reactive({
    chosen_motif <- motifs[[input[["chosen_motif"]]]]
    
    if(input[["protein_type"]] == "Only amyloids")
      chosen_motif <- chosen_motif[chosen_motif[["amyloid"]], ]
    
    if(input[["protein_type"]] == "Only non-amyloids")
      chosen_motif <- chosen_motif[!chosen_motif[["amyloid"]], ]
    
    if(input[["only_motif"]])
      chosen_motif <- chosen_motif[grepl("font color", chosen_motif[["colored"]]), ]
    
    chosen_motif <- chosen_motif[grepl(input[["chosen_name"]], chosen_motif[["name"]], ignore.case = TRUE), ]
    
    chosen_motif
  })
  
  output[["motif_occ"]] <- renderPlot({
    # better count the maximum possible total number of motifs in a seq of given n
    max_occ <- chosen_motif_r()[["seq_len"]] - nchar(input[["chosen_motif"]]) + 1
    
    motif_freq <- chosen_motif_r()[["n_times"]]/max_occ
    #chosen_motif[["n_times"]]
    #chosen_motif[["n_times"]] > 1
    
    plot_df <- data.frame(motif_freq = motif_freq, 
                          n_times = chosen_motif_r()[["n_times"]],
                          amyloid = chosen_motif_r()[["amyloid"]])
    
    if(input[["plot_type"]] == "Frequency density")
      p <- ggplot(plot_df, aes(x = motif_freq, fill = amyloid)) +
      geom_density(alpha = 0.2) +
      scale_x_continuous("Motif frequency density")
    
    if(input[["plot_type"]] == "Absolute occurrence")
      p <- ggplot(plot_df, aes(x = n_times, fill = amyloid)) +
      geom_density(alpha = 0.2) +
      scale_x_continuous("Motif absolute occurrence density")
    
    if(input[["plot_type"]] == "Absolute presence")
      p <- ggplot(plot_df, aes(x = amyloid, fill = amyloid)) +
      geom_bar() +
      scale_x_discrete("Motif absolute presence density")
    
    p + ggtitle(paste0("Motif: ", input[["chosen_motif"]]))
  })
  
  output[["motif_text"]] <- renderText({
    
    if(nrow(chosen_motif_r()) == 0) {
      "No sequences found." 
    } else {
      sapply(1L:nrow(chosen_motif_r()), function(i) {
        
        motif_name <- ifelse(chosen_motif_r()[i, "amyloid"], 
                             paste0('<font color = "blue">', chosen_motif_r()[i, "name"], "</font>"),
                             chosen_motif_r()[i, "name"])
        paste0(motif_name, "<br>", chosen_motif_r()[i, "colored"], "<br><br>")
      })
    }
  })
  
})
