library(shiny)

shinyUI(fluidPage(
  theme = shinythemes::shinytheme("spacelab"),
  
  titlePanel("Amyloid motifs"),
  
  sidebarLayout(
    sidebarPanel(
      includeMarkdown("intro.md"),
      selectInput("protein_type",
                  "Type of peptide/protein",
                  choices = c("All", "Only amyloids", "Only non-amyloids")),
      selectInput("chosen_motif",
                  "Select n-gram motif",
                  choices = c("2", "6_66", "6___2", "6__2", "2___6", "6_2", "26", "2__6", 
                              "2_6", "366", "2___2", "32", "6_62", "662", "66_2", "6_26", "2_66", 
                              "62_6", "626", "266", "22", "2_1", "2_36", "22_6", "622", "351", 
                              "4_35", "33_1", "33_5", "343", "43_4", "5_33", "3_35", "34_6", 
                              "533", "3_43", "335", "436", "433", "35_6", "6_43", "3_33", "643", 
                              "33_3", "64_3", "33_4", "33_6", "35", "334", "4__3", "3__4", 
                              "63_3", "336", "3_36", "5__3", "333", "633", "4_3", "43", "34", 
                              "3_4", "3__3", "6_33", "6___3", "3")),
      checkboxInput("only_motif",
                    "Select only proteins with motif"),
      textInput("chosen_name", "Name or type of the sequence (partial matching allowed)", value = ""),
      plotOutput("motif_occ"),
      selectInput("plot_type",
                  "Type of plot",
                  choices = c("Frequency density", "Absolute occurrence", "Absolute presence"))
    ),
    
    mainPanel(
      htmlOutput("motif_text")
    )
  )
))
