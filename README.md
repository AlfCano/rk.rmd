# rk.rmd: R Markdown & Academic Boilerplates for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.rmd/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.rmd/actions/workflows/lintr.yml)

**rk.rmd** brings a visual, intuitive boilerplate generator for R Markdown directly to the RKWard GUI. Stop struggling with complex YAML syntax, LaTeX preamble configurations, or trying to remember how to properly link authors to multiple institutions in APA format. 

With this plugin suite, you can generate perfectly formatted `.Rmd` templates for standard reports, academic journals, and APA manuscripts in seconds.

## 🚀 What's New in Version 0.0.1

This is the initial release of the package, introducing three highly requested tools for reproducible research and document generation:

1.  **Document Builder:** Generate customizable YAML headers for standard HTML, PDF, and Word documents, or select advanced journal templates from the `rticles` package (Elsevier, IEEE, Springer).
2.  **Markdown Cheat Sheet:** Instantly inject proper Markdown syntax for text formatting, math equations, tables, and R code chunks based on the official Posit/RStudio cheat sheets.
3.  **APA Manuscript (papaja):** A dedicated, advanced builder to generate APA 6th and 7th edition manuscripts using the `papaja` package. Features a spreadsheet interface to easily manage multiple authors, complex affiliations, and peer-review masking.

### 🌍 Internationalization
The interface is fully localized in:
*   🇺🇸 English (Default)
*   🇪🇸 Spanish (`es`)
*   🇫🇷 French (`fr`)
*   🇩🇪 German (`de`)
*   🇧🇷 Portuguese (Brazil) (`pt_BR`)

## ✨ Features

### 1. Visual YAML Generation
*   **No Syntax Errors:** The plugin safely sanitizes your inputs and generates strict, error-free YAML metadata (`yaml::as.yaml()`).
*   **Themes & TOC:** Toggle Table of Contents, section numbering, and HTML themes (Cerulean, Flatly, Journal) with simple checkboxes.
*   **Export Options:** Output the generated template to the RKWard console to copy-paste it, or save it directly to your hard drive as an `.Rmd` file.

### 2. Painless APA Formatting (`papaja`)
*   **Author/Affiliation Matrices:** Easily assign multiple institutions to a single author (e.g., `1, 2`) or designate corresponding authors using a clean spreadsheet widget.
*   **Academic Settings:** One-click toggles for line numbers, floating figures/tables integration (`floatsintext`), and author masking for blind peer-reviews.

### 3. Quick Snippets
*   Forget how to write a native Markdown table or a hidden R chunk (`echo=FALSE, results='hide'`)? The Cheat Sheet component generates the exact code you need instantly.

## 📦 Installation

This plugin is available via GitHub. Use the `remotes` or `devtools` package in RKWard to install it.

1.  **Open RKWard**.
2.  **Run the following command** in the R Console:

    ```R
    # If you don't have devtools installed:
    # install.packages("devtools")
    
    local({
      require(devtools)
      install_github("AlfCano/rk.rmd", force = TRUE)
    })
    ```
3.  **Restart RKWard** to load the new menu entries.

## 💻 Usage & Testing Instructions

Once installed, the tools are organized under the main File menu (the standard location for document creation tools):

**`File` -> `R Markdown Generators`**

### Test 1: Generate an APA 7th Edition Paper
1. Go to **File -> R Markdown Generators -> 3. APA Manuscript (papaja)**.
2. **Title & Abstract:** Enter "My Groundbreaking Study" as Title and "SHORT TITLE" as Running Head.
3. **Authors:** 
   * In the *Define Affiliations* matrix, add `1` and `University of Science`.
   * In the *Define Authors* matrix, add `Jane Doe`, Affil ID `1`, Corresponding `yes`, and an email.
4. **Settings:** Select **APA 7th Edition**, check "Masked for Peer Review".
5. **Export:** Click the folder icon, choose your Desktop, and name it `apa_test.Rmd`.
6. Click **Submit**. Open the newly created `apa_test.Rmd` in your text editor and enjoy the perfectly formatted YAML!

### Test 2: Standard Report with TOC
1. Go to **1. Document Builder (Standard & General Templates)**.
2. Enter your title, check **Include Table of Contents**, and select the **Cerulean** HTML theme.
3. Click **Submit**. Copy the code directly from the RKWard output window into your script.

## 🛠️ Dependencies

This plugin relies on the following R packages:
*   `yaml` (Required to strictly generate the `.Rmd` headers)
*   `rkwarddev` (Plugin generation)
*   *Note: While not required to generate the text files, you will need `rmarkdown`, `rticles`, and `papaja` installed in R to actually knit/render the generated documents.*

## ✍️ Author & License

*   **Author:** Alfonso Cano (<alfonso.cano@correo.buap.mx>)
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)
