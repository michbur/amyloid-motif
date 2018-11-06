# read files from AmyPro database (FASTA file export)

read_amypro <- function(file) {
  amypro_seqs <- read_fasta(file)
  
  lapply(names(amypro_seqs), read_amypro_single, amypro_seqs = amypro_seqs) %>% 
    bind_rows()
}

read_amypro_single <- function(ith_seq_name, amypro_seqs) {
  # start of the amyloid region followed by the start of the closest non-amyloid region
  region_starts <- strsplit(ith_seq_name, "regions=[", fixed = TRUE)[[1]][2] %>% 
    strsplit(x = ., split = "]", fixed = TRUE) %>% 
    unlist %>% 
    first %>%  
    strsplit(., ",") %>% 
    unlist %>% 
    strsplit(., "-") %>% 
    lapply(as.numeric) %>% 
    lapply(function(i) c(i[1], i[2] + 1)) 
  
  prot_len <- 1L:length(amypro_seqs[[ith_seq_name]])
  region_pos <- cumsum(prot_len %in% unlist(region_starts))
  
  amyloid_starts <- sapply(region_starts, first)
  
  amyloid_status <- sapply(split(prot_len, region_pos), function(ith_region)
    any(ith_region %in% amyloid_starts))
  
  region_seq <- sapply(split(amypro_seqs[[ith_seq_name]], region_pos), paste0, collapse = "")
  
  data.frame(name = ith_seq_name,
             region_id = 1L:length(region_seq),
             seq = region_seq,
             amyloid = amyloid_status, 
             stringsAsFactors = FALSE)
}
