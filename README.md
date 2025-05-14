# DrugBank XML Parser

This R script parses the DrugBank full database XML file and extracts several biologically relevant tables, including drug metadata, interactions, SNP-related information, and protein targets.

## 📦 Output Files

The script generates the following CSV files inside the `~/drubank_data/New data/` directory:

- `main_df.csv`: Core drug information  
- `interactions_df.csv`: Drug-drug interaction data  
- `external_ids_df.csv`: External database identifiers (e.g., ChEMBL, PubChem)  
- `snp_effects_df.csv`: SNP effects related to drug response  
- `snp_adrs_df.csv`: SNPs associated with adverse drug reactions  
- `targets_df.csv`: Drug target proteins and actions  

---

## 🧪 Requirements

The following R packages are required:

```r
install.packages(c("xml2", "dplyr", "purrr", "progress"))

# 📝 Note:
# The file `drugbank.xsd` is included in the repository for reference only.
# It was used to understand the XML structure of the DrugBank database
# and guide the XPath queries in the script.
# The parser itself does not require or validate against the schema file.
