library(shiny)
load("motifs.RData")

shinyServer(function(input, output) {
  
  output[["motif_text"]] <- renderText({
    chosen_motif <- motifs[[input[["chosen_motif"]]]]

    if(input[["protein_type"]] == "Only amyloids")
      chosen_motif <- chosen_motif[chosen_motif[["amyloid"]], ]
    
    if(input[["protein_type"]] == "Only non-amyloids")
      chosen_motif <- chosen_motif[!chosen_motif[["amyloid"]], ]

    if(input[["only_motif"]])
      chosen_motif <- chosen_motif[grepl("font color", chosen_motif[["colored"]]), ]
    
    chosen_motif <- chosen_motif[grepl(input[["chosen_name"]], chosen_motif[["name"]], ignore.case = TRUE), ]
    
    sapply(1L:nrow(chosen_motif), function(i) {
      
      motif_name <- ifelse(chosen_motif[i, "amyloid"], 
                           paste0('<font color = "blue">', chosen_motif[i, "name"], "</font>"),
                           chosen_motif[i, "name"])
      paste0(motif_name, "<br>", chosen_motif[i, "colored"], "<br><br>")
    })
  })
  
})
