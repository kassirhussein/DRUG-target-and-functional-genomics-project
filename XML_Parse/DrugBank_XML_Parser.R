# DrugBank XML Parser
# Author: [Your Name]
# Description: Parses the DrugBank full database XML into tidy data frames.
# Outputs: Multiple CSVs with drug information

library(xml2)
library(dplyr)
library(purrr)
library(progress)

# Load XML
drugbank_data <- read_xml("drubank_data/full database.xml")
ns <- xml_ns(drugbank_data)
drug_nodes <- xml_find_all(drugbank_data, ".//d1:drug", ns)

# Utility function to safely get text values
get_texts <- function(node, xpath) {
  vals <- xml_text(xml_find_all(node, xpath, ns))
  paste(vals[vals != ""], collapse = "; ")
}

# Create output directory
output_dir <- "~/drubank_data/New data"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ------------------------------
# MAIN TABLE
# ------------------------------
pb <- progress_bar$new(
  total = length(drug_nodes),
  format = "Main Table [:bar] :current/:total (:percent) eta: :eta",
  clear = FALSE, width = 60
)

main_df <- map_dfr(drug_nodes, function(drug) {
  pb$tick()
  tibble(
    drugbank_id = xml_text(xml_find_first(drug, "./d1:drugbank-id[@primary='true']", ns)),
    name = xml_text(xml_find_first(drug, "./d1:name", ns)),
    groups = get_texts(drug, "./d1:groups/d1:group"),
    indication = xml_text(xml_find_first(drug, "./d1:indication", ns)),
    mechanism_of_action = xml_text(xml_find_first(drug, "./d1:mechanism-of-action", ns)),
    affected_organisms = get_texts(drug, "./d1:affected-organisms/d1:affected-organism"),
    chembl_id = xml_text(xml_find_first(
      drug, "./d1:external-identifiers/d1:external-identifier[d1:resource='ChEMBL']/d1:identifier", ns))
  )
})

write.csv(main_df, file.path(output_dir, "main_df.csv"), row.names = FALSE)

# ------------------------------
# DRUG INTERACTIONS
# ------------------------------
pb <- progress_bar$new(
  total = length(drug_nodes),
  format = "Drug Interactions [:bar] :current/:total (:percent) eta: :eta",
  clear = FALSE, width = 60
)

interactions_df <- map_dfr(drug_nodes, function(drug) {
  pb$tick()
  id <- xml_text(xml_find_first(drug, "./d1:drugbank-id[@primary='true']", ns))
  interactions <- xml_find_all(drug, "./d1:drug-interactions/d1:drug-interaction", ns)
  map_dfr(interactions, function(inter) {
    tibble(
      drugbank_id = id,
      interacting_drug = xml_text(xml_find_first(inter, "./d1:name", ns)),
      description = xml_text(xml_find_first(inter, "./d1:description", ns))
    )
  })
})

write.csv(interactions_df, file.path(output_dir, "interactions_df.csv"), row.names = FALSE)

# ------------------------------
# EXTERNAL IDENTIFIERS
# ------------------------------
pb <- progress_bar$new(
  total = length(drug_nodes),
  format = "External IDs [:bar] :current/:total (:percent) eta: :eta",
  clear = FALSE, width = 60
)

external_ids_df <- map_dfr(drug_nodes, function(drug) {
  pb$tick()
  id <- xml_text(xml_find_first(drug, "./d1:drugbank-id[@primary='true']", ns))
  ex_ids <- xml_find_all(drug, "./d1:external-identifiers/d1:external-identifier", ns)
  map_dfr(ex_ids, function(ex) {
    tibble(
      drugbank_id = id,
      resource = xml_text(xml_find_first(ex, "./d1:resource", ns)),
      identifier = xml_text(xml_find_first(ex, "./d1:identifier", ns))
    )
  })
})

write.csv(external_ids_df, file.path(output_dir, "external_ids_df.csv"), row.names = FALSE)

# ------------------------------
# SNP EFFECTS
# ------------------------------
pb <- progress_bar$new(
  total = length(drug_nodes),
  format = "SNP Effects [:bar] :current/:total (:percent) eta: :eta",
  clear = FALSE, width = 60
)

snp_effects_df <- map_dfr(drug_nodes, function(drug) {
  pb$tick()
  id <- xml_text(xml_find_first(drug, "./d1:drugbank-id[@primary='true']", ns))
  effects <- xml_find_all(drug, ".//d1:snp-effects/d1:effect", ns)
  map_dfr(effects, function(effect) {
    tibble(
      drugbank_id = id,
      protein_name = xml_text(xml_find_first(effect, "./d1:protein-name", ns)),
      gene_symbol = xml_text(xml_find_first(effect, "./d1:gene-symbol", ns)),
      uniprot_id = xml_text(xml_find_first(effect, "./d1:uniprot-id", ns)),
      rs_id = xml_text(xml_find_first(effect, "./d1:rs-id", ns)),
      allele = xml_text(xml_find_first(effect, "./d1:allele", ns)),
      defining_change = xml_text(xml_find_first(effect, "./d1:defining-change", ns)),
      description = xml_text(xml_find_first(effect, "./d1:description", ns)),
      pubmed_id = xml_text(xml_find_first(effect, "./d1:pubmed-id", ns))
    )
  })
})

write.csv(snp_effects_df, file.path(output_dir, "snp_effects_df.csv"), row.names = FALSE)

# ------------------------------
# SNP ADRs
# ------------------------------
pb <- progress_bar$new(
  total = length(drug_nodes),
  format = "SNP ADRs [:bar] :current/:total (:percent) eta: :eta",
  clear = FALSE, width = 60
)

snp_adrs_df <- map_dfr(drug_nodes, function(drug) {
  pb$tick()
  id <- xml_text(xml_find_first(drug, "./d1:drugbank-id[@primary='true']", ns))
  adrs <- xml_find_all(drug, ".//d1:snp-adverse-drug-reactions/d1:reaction", ns)
  map_dfr(adrs, function(adr) {
    tibble(
      drugbank_id = id,
      protein_name = xml_text(xml_find_first(adr, "./d1:protein-name", ns)),
      gene_symbol = xml_text(xml_find_first(adr, "./d1:gene-symbol", ns)),
      uniprot_id = xml_text(xml_find_first(adr, "./d1:uniprot-id", ns)),
      rs_id = xml_text(xml_find_first(adr, "./d1:rs-id", ns)),
      allele = xml_text(xml_find_first(adr, "./d1:allele", ns)),
      reaction = xml_text(xml_find_first(adr, "./d1:adverse-reaction", ns)),
      description = xml_text(xml_find_first(adr, "./d1:description", ns)),
      pubmed_id = xml_text(xml_find_first(adr, "./d1:pubmed-id", ns))
    )
  })
})

write.csv(snp_adrs_df, file.path(output_dir, "snp_adrs_df.csv"), row.names = FALSE)

# ------------------------------
# TARGETS
# ------------------------------
pb <- progress_bar$new(
  total = length(drug_nodes),
  format = "Targets [:bar] :current/:total (:percent) eta: :eta",
  clear = FALSE, width = 60
)

targets_df <- map_dfr(drug_nodes, function(drug) {
  pb$tick()
  id <- xml_text(xml_find_first(drug, "./d1:drugbank-id[@primary='true']", ns))
  targets <- xml_find_all(drug, "./d1:targets/d1:target", ns)
  map_dfr(targets, function(target) {
    tibble(
      drugbank_id = id,
      name = xml_text(xml_find_first(target, "./d1:name", ns)),
      organism = xml_text(xml_find_first(target, "./d1:organism", ns)),
      gene_name = xml_text(xml_find_first(target, ".//d1:gene-name", ns)),
      actions = get_texts(target, "./d1:actions/d1:action"),
      known_action = xml_text(xml_find_first(target, "./d1:known-action", ns))
    )
  })
})

write.csv(targets_df, file.path(output_dir, "targets_df.csv"), row.names = FALSE)
