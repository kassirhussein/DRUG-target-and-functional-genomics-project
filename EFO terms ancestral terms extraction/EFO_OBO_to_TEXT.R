# -------------------------------------------------------------------------
# Project      : Ontologies
# Script       : EFO_obo_to_txt.R
# Description  : Imports the EFO Ontology (OBO format) and extracts key 
#                relationships (parents, children, ancestors) into plain text.
# Author       : Hussein
# Contributor  : Dr. Pilar Cacheiro
# Credit       : Code structure and functions adapted from 
#                https://github.com/pilarcacheiro/Ontologies
# -------------------------------------------------------------------------







# install / load libraries ------------------------------------------------

if (!require("ontologyIndex")) install.packages("ontologyIndex")
library("ontologyIndex")

if (!require("dplyr")) install.packages("dplyr")
library("dplyr")

if (!require("tidyr")) install.packages("tidyr")
library("tidyr")

if (!require("Hmisc")) install.packages("Hmisc")
library("Hmisc")

# Load the MONDO Data ---------------------------------

efo <- get_ontology("http://www.ebi.ac.uk/efo/efo.obo")

#mondo id and description

efo_description <- data.frame(
  efo_term = as.character(row.names(as.data.frame(efo[[2]]))),
  efo_description = as.character(as.data.frame(efo[[2]])[, 1]), 
  stringsAsFactors = F)


## parents, children and all the ancestors for a given efo term as a list

parents <- efo[[3]]
children <-  efo[[4]]
ancestors <- efo[[5]]



# set of functions to convert these lists to data frames ------------------


## get parental nodes 

get_parent_nodes <- function(parents) {
  
  efo_term <- list()
  efo_parents <-list()
  
  for(i in 1:length(names(parents))){
    
    efo_term [[i]] <- names(parents)[i]
    efo_parents[[i]] <- paste(parents[[i]], collapse=",")
  }
  
  efo_parents <- data.frame(
    efo_term = do.call(rbind,efo_term), 
    efo_parents = do.call(rbind, efo_parents), stringsAsFactors = F) %>%
    mutate(efo_parents = strsplit(as.character(efo_parents), ",")) %>%
    unnest(efo_parents) %>%
    filter(efo_term != efo_parents)
  
  return(efo_parents)
  
}


## get children nodes 

get_children_nodes <- function(children) {
  
  efo_term <- list()
  efo_children <- list()
  
  for(i in 1:length(names(children))){
    
    efo_term [[i]] <- names(children)[i]
    efo_children[[i]] <- paste(children[[i]], collapse=",")
  }
  
  efo_children <-  data.frame(
    efo_term = do.call(rbind, efo_term),
    efo_children = do.call(rbind, efo_children), stringsAsFactors = F) %>%
    mutate(efo_children = strsplit(as.character(efo_children), ",")) %>%
    unnest(efo_children) %>%
    filter(efo_term != efo_children)
  
  return(efo_children)
}


## get all the ancestors/ top levels

get_ancestor_nodes <- function(ancestors) {
  
  efo_term <- list()
  efo_ancestors <- list()
  
  for(i in 1:length(names(ancestors))) {
    
    efo_term [[i]] <- names(ancestors)[i]
    efo_ancestors[[i]] <- paste(ancestors[[i]], collapse=",")
  }
  
  efo_ancestors <- data.frame(
    efo_term = do.call(rbind, efo_term),
    efo_ancestors = do.call(rbind, efo_ancestors),stringsAsFactors = F) %>%
    mutate(efo_ancestors = strsplit(as.character(efo_ancestors), ",")) %>%
    unnest(efo_ancestors) %>%
    filter(efo_term != efo_ancestors )
  
  return(efo_ancestors)
}

## get top levels of the ontology (physiological systems)

efo_toplevels <- get_parent_nodes(parents) %>%
  filter(efo_parents == "BFO:0000016") %>%
  left_join(efo_description,by = "efo_term") %>%
  select(efo_term, efo_description)

efo_toplevels_phenotypic_abnormalities_only <- get_parent_nodes(parents) %>%
  filter(efo_parents == "efo:EFO_0000408") %>%
  left_join(efo_description,by = "efo_term") %>%
  select(efo_term,efo_description)


# apply functions ---------------------------------------------------------


efo_parental_nodes <- get_parent_nodes(parents)

efo_children_nodes <- get_children_nodes(children)

efo_ancestor_nodes <- get_ancestor_nodes(ancestors)


# export files ------------------------------------------------------------


efo_dir <- "./data_efo/"


files_to_export <- list(efo_description, 
                        efo_parental_nodes,
                        efo_children_nodes,
                        efo_ancestor_nodes,
                        efo_toplevels,
                        efo_toplevels_phenotypic_abnormalities_only)

names(files_to_export) <- Cs(efo_description,
                             efo_parental_nodes,
                             efo_children_nodes,
                             efo_ancestor_nodes,
                             efo_toplevels,
                             efo_toplevels_phenotypic_abnormalities_only)


for (i in 1:length(files_to_export)){
  
  write.table(files_to_export[[i]],
              paste0(efo_dir, names(files_to_export)[i], ".txt"), 
              quote = F, sep = "\t", row.names = FALSE)
  
}




# Create the directory if it doesn't exist
if (!dir.exists(efo_dir)) {
  dir.create(efo_dir, recursive = TRUE)
}

# Now write the files
for (i in 1:length(files_to_export)) {
  write.table(files_to_export[[i]],
              paste0(efo_dir, names(files_to_export)[i], ".txt"), 
              quote = FALSE, sep = "\t", row.names = FALSE)
}






# --- Code above adapted from https://github.com/pilarcacheiro/Ontologies ---
# Original logic by Dr. Pialr Cacheiro






# MONDO_TOP_LEVEL_DATA_WRANGLING ----------------------


library(tidyverse)

efo_description <- read.delim("./data_efo/efo_description.txt")
efo_parental_nodes <- read.delim("./data_efo/efo_parental_nodes.txt")
efo_children_nodes <- read.delim("./data_efo/efo_children_nodes.txt")
efo_ancestor_nodes <- read.delim("./data_efo/efo_ancestor_nodes.txt")
efo_toplevels <- read.delim("./data_efo/efo_toplevels.txt")
efo_toplevels_phenotypic_abnormalities_only <- read.delim("./data_efo/efo_toplevels_phenotypic_abnormalities_only.txt")


efo_ancestor_filtered <- efo_ancestor_nodes %>%
  filter(efo_ancestors %in% efo_toplevels_phenotypic_abnormalities_only$efo_term) %>%
  left_join(efo_description, by = "efo_term") %>%
  left_join(efo_toplevels_phenotypic_abnormalities_only, by = c("efo_ancestors" = "efo_term"))


# Rearrange and rename columns

efo_ancestor_arranged <- efo_ancestor_filtered %>%
  rename("efo_term_id" = "efo_term") %>%
  rename("efo_ancestor_id" = "efo_ancestors") %>%
  rename("efo_term_description" = "efo_description.x") %>%
  rename("efo_ancestor_description" = "efo_description.y")


# Export table

efo_dir <- "./data_efo/"

write.table(efo_ancestor_arranged,
            paste0(efo_dir, "efo_ancestor_terms.txt"),  
            quote = FALSE, sep = "\t", row.names = FALSE)
