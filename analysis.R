library(dplyr)
library(biogram)
library(AmyloGram)
library(gsubfn)
library(stringr)

source("./functions/read_amypro.R")

ngram_freq <- read.csv("./data/ngram_freq.csv") %>% 
  mutate(regexp = gsub("_", paste0(c("[", toupper(biogram:::return_elements("prot")), "]"), collapse = ""), 
                       decoded_name, fixed = TRUE))

amylogram_alph <- lapply(AmyloGram_model[["enc"]], toupper)

# motifs that cannot be found in other motifs
# unique_motif <- sapply(ngram_freq[["regexp"]], function(ith_motif) 
#  sum(grepl(pattern = ith_motif, x = ngram_freq[["decoded_name"]]))) == 1

neg_seqs <- read_fasta("./data/amyload-negative.fasta") %>% 
  sapply(paste0, collapse = "")

pos_seqs <- read_fasta("./data/amyload-positive.fasta") %>% 
  sapply(paste0, collapse = "")

pos_seqs[pos_seqs %in% neg_seqs]
neg_seqs[neg_seqs %in% pos_seqs]
# VTQEFW - the same seq in two data sets

pos_seqs_unique <- pos_seqs[pos_seqs != "VTQEFW"]
neg_seqs_unique <- neg_seqs[neg_seqs != "VTQEFW"]


amypro_raw <- readLines("./data/amypro.txt") %>% 
  strsplit("\t") %>% 
  do.call(rbind, .)

colnames(amypro_raw) <- amypro_raw[1, ]
amypro_df <- data.frame(amypro_raw[-1, ], stringsAsFactors = FALSE) %>% 
  mutate(prion = prion == "yes",
       nice_name = paste0(ID, " ", protein, ifelse(prion, " (prion)", ""))) %>% 
  select(ID, nice_name)

amypro_fasta <- read_amypro("./data/amypro.fasta") %>% 
  mutate(ID = sapply(strsplit(name, " "), first)) %>% 
  inner_join(amypro_df) %>% 
  select(-ID, -name) %>% 
  rename(name = nice_name) %>% 
  mutate(name = paste0(name, " R", region_id))

seqs_df <-  bind_rows(amypro_fasta, 
                      data.frame(name = names(pos_seqs_unique),
                                 region_id = 1,
                                 seq = pos_seqs_unique,
                                 amyloid = TRUE, 
                                 stringsAsFactors = FALSE),
                      data.frame(name = names(neg_seqs_unique),
                                 region_id = 1,
                                 seq = neg_seqs_unique,
                                 amyloid = FALSE, 
                                 stringsAsFactors = FALSE)) %>% 
  mutate(name = paste0(name, ifelse(amyloid, " (amyloid)", " (non-amyloid)")))

# <font color = "red"></font>

insert_br <- function(x, single_line_len = 60) {
  len <- nchar(x)
  if(len > single_line_len) {
    paste0(read.fwf(textConnection(x), rep(single_line_len, (len %/% single_line_len + 1)), as.is = TRUE), collapse = "<br>")
  } else {
    x
  }
}
# insert_br("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")


motifs <- lapply(ngram_freq[["regexp"]], function(ith_regexp) {
  for(i in names(amylogram_alph)) 
    ith_regexp <- gsub(pattern = i, replacement = paste0(c("[", amylogram_alph[[i]], "]"), collapse = ""), x = ith_regexp)
  
  #labels_colors <- c("chartreuse3", "dodgerblue2", "firebrick1", "darkorange", "darkseagreen4", "darkorchid3")
  mutate(seqs_df, 
         colored = sapply(seq, insert_br),
         colored = gsubfn(pattern = ith_regexp, replacement = function(x) paste0('<font color = "red">', x, "</font>"), 
                                   x = colored),
         n_times = str_count(string = colored, "color"),
         seq_len = nchar(seq))
})

names(motifs) <- as.character(ngram_freq[["decoded_name"]])

save(motifs, file = "./motif-searcher/motifs.RData")

