# EFO Ontology Processor

This R script imports the **Experimental Factor Ontology (EFO)** in `.obo` format and extracts ontology relationships including **descriptions, parent-child relationships, and ancestors**. Outputs are saved as plain text files for downstream processing or integration.

---

##  Script Details

- **Script Name:** `EFO_obo_to_txt.R`
- **Author:** Hussein
- **Contributor:** Dr. Pilar Cacheiro
- **Description:** Parses and flattens the EFO ontology tree structure and exports key term relationships.
- **License:** MIT (or your preferred license)

---

##  Requirements

- R (>= 4.0.0)
- Packages:
  - `ontologyIndex`
  - `dplyr`
  - `tidyr`
  - `Hmisc`
  - `readr`
  - `tibble`

### Install dependencies

```r
install.packages(c("ontologyIndex", "dplyr", "tidyr", "Hmisc"))
```

---

##  Inputs & Outputs

###  Inputs:
- The EFO `.obo` file is retrieved directly from:
  ```
  http://www.ebi.ac.uk/efo/efo.obo
  ```

###  Outputs (all saved in `./data_efo/`):
- `efo_description.txt`  
- `efo_parental_nodes.txt`  
- `efo_children_nodes.txt`  
- `efo_ancestor_nodes.txt`  
- `efo_toplevels.txt`  
- `efo_toplevels_phenotypic_abnormalities_only.txt`  
- `efo_ancestor_terms.txt` *(final table combining ancestry relationships with descriptions)*

---

##  Key Functions

The script includes custom logic to:
- Parse EFO terms and their relationships
- Extract and flatten parent/child/ancestor nodes
- Filter and match top-level ontology terms
- Export clean, tab-separated tables

---

##  Acknowledgments

This script is **adapted in part** from the work of **Dr. Pilar Cacheiro**.  
Original codebase available at: [https://github.com/pilarcacheiro/Ontologies](https://github.com/pilarcacheiro/Ontologies)

Specific functions and structure (e.g., `get_parent_nodes`, `get_children_nodes`, and ontology wrangling) follow her original approach and logic.

---

##  License

MIT License (or specify another if needed)

---

##  Contact

For feedback, questions, or contributions, feel free to open an issue or fork the repo.






