library(dplyr)
library(biogram)

ngram_freq <- read.csv("./data/ngram_freq.csv") %>% 
  mutate(regexp = gsub("_", paste0(c("[", 1L:6, "_", "]"), collapse = ""), decoded_name, fixed = TRUE))

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
