local({
  # =========================================================================================
  # 1. Metadata and Setup
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.rmd",
    author = person(
      given = "Alfonso",
      family = "Cano Robles",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "RKWard Plugin Suite for generating R Markdown, papaja, and bookdown boilerplates.",
      version = "0.0.1",
      url = "https://github.com/AlfCano/rk.rmd",
      license = "GPL (>= 3)"
    )
  )

  common_hierarchy <- list("file", "R Markdown Generators")

  js_sanitize_input <- "
    function cleanStr(val) {
        if(!val) return '';
        return val.replace(/'/g, \"\\\\'\").replace(/\"/g, '\\\\\"').replace(/\\n/g, '\\\\n');
    }
  "

  # =========================================================================================
  # MAIN PLUGIN: Document Builder
  # =========================================================================================
  help_std <- rk.rkh.doc(title = rk.rkh.title("1. Document Builder"), summary = rk.rkh.summary("Generates a copy-pasteable R Markdown YAML header."))

  c1_title  <- rk.XML.input("Document Title", initial = "Untitled Analysis", required = TRUE, id.name = "c1_title")
  c1_author <- rk.XML.input("Author Name(s)", initial = "Jane Doe", required = FALSE, id.name = "c1_author")
  c1_date   <- rk.XML.cbox("Use Current Date (Sys.Date)", value = "TRUE", chk = TRUE, id.name = "c1_date")

  c1_template <- rk.XML.dropdown("Document Template (Overrides Standard Output)", options = list(
    "Standard Format (Basic HTML/PDF/Word)" = list(val = "standard", chk = TRUE),
    "Elsevier Journal Article (rticles)"    = list(val = "rticles::elsevier_article"),
    "IEEE Transaction (rticles)"            = list(val = "rticles::ieee_article"),
    "Springer Journal (rticles)"            = list(val = "rticles::springer_article")
  ), id.name = "c1_template")

  c1_format <- rk.XML.dropdown("Standard Output Format", options = list("HTML Document" = list(val = "html_document", chk = TRUE), "PDF Document" = list(val = "pdf_document"), "Word Document" = list(val = "word_document")), id.name = "c1_format")
  c1_theme <- rk.XML.dropdown("HTML Theme (HTML only)", options = list("Default" = list(val = "default", chk = TRUE), "Cerulean" = list(val = "cerulean"), "Flatly" = list(val = "flatly"), "Journal" = list(val = "journal")), id.name = "c1_theme")
  c1_toc    <- rk.XML.cbox("Include Table of Contents (TOC)", value = "TRUE", chk = FALSE, id.name = "c1_toc")
  c1_number <- rk.XML.cbox("Number Sections", value = "TRUE", chk = FALSE, id.name = "c1_number")
  c1_save_opt <- rk.XML.browser("Optional: Save directly to .Rmd file", type = "savefile", required = FALSE, id.name = "c1_save_opt")

  tab_c1_meta <- rk.XML.col(c1_title, c1_author, c1_date)
  tab_c1_opts <- rk.XML.col(rk.XML.frame(c1_template, label="Academic Templates"), rk.XML.frame(c1_format, c1_theme, c1_toc, c1_number, label="Standard Options"))
  tab_c1_out  <- rk.XML.col(rk.XML.text("By default, the code will be printed to the RKWard output window. You can optionally save it directly to a file here:"), c1_save_opt)

  dialog_std <- rk.XML.dialog(label = "1. Document Builder", child = rk.XML.tabbook(tabs = list("Metadata" = tab_c1_meta, "Output & Templates" = tab_c1_opts, "Export" = tab_c1_out)))

  js_calc_std <- paste0(js_sanitize_input, "
    var title = cleanStr(getValue('c1_title')); var author = cleanStr(getValue('c1_author')); var template = getValue('c1_template');
    var format = getValue('c1_format'); var theme = getValue('c1_theme');
    var hasTOC = getValue('c1_toc') == 'TRUE'; var hasNum = getValue('c1_number') == 'TRUE'; var doDate = getValue('c1_date') == 'TRUE';

    echo('rmd_meta <- list()\\n');
    echo('rmd_meta$title <- \"' + title + '\"\\n');
    if (author != '') echo('rmd_meta$author <- \"' + author + '\"\\n');
    if (doDate) echo('rmd_meta$date <- format(Sys.Date(), \"%Y-%m-%d\")\\n');

    if (template == 'standard') {
        echo('fmt_opts <- list()\\n');
        if (hasTOC) echo('fmt_opts$toc <- TRUE\\n');
        if (hasNum) echo('fmt_opts$number_sections <- TRUE\\n');
        if (format == 'html_document' && theme != 'default') echo('fmt_opts$theme <- \"' + theme + '\"\\n');

        echo('rmd_meta$output <- list()\\n');
        echo('if(length(fmt_opts) > 0) { rmd_meta$output[[\"' + format + '\"]] <- fmt_opts } else { rmd_meta$output <- \"' + format + '\" }\\n');
    } else {
        echo('rmd_meta$output <- \"' + template + '\"\\n');
        echo('rmd_meta$bibliography <- \"references.bib\"\\n');
    }

    echo('yaml_str <- yaml::as.yaml(rmd_meta)\\n');
    echo('full_rmd <- paste0(\"---\\\\n\", yaml_str, \"---\\\\n\\\\n```{r setup, include=FALSE}\\\\nknitr::opts_chunk$set(echo = TRUE)\\\\n```\\\\n\\\\n## Introduction\\\\n\\\\nStart writing here...\\\\n\")\\n');
  ")

  js_print_std <- "
    var savefile = getValue('c1_save_opt');
    echo('rk.header(\"Generated Document Boilerplate\", level=2)\\n');
    echo('cat(\"\\\\n============================================================\\\\n\")\\n');
    echo('cat(full_rmd)\\n');
    echo('cat(\"============================================================\\\\n\\\\n\")\\n');

    if (savefile != '') {
        echo('save_path <- \"' + savefile + '\"\\n');
        echo('if (!grepl(\"\\\\\\\\.Rmd$\", save_path, ignore.case = TRUE)) { save_path <- paste0(save_path, \".Rmd\") }\\n');
        echo('writeLines(full_rmd, con = save_path)\\n');
        echo('rk.print(paste(\"File successfully saved to:\", save_path))\\n');
    }
  "

  # =========================================================================================
  # SUB-COMPONENT 2: Markdown Posit Cheat Sheet
  # =========================================================================================
  help_snip <- rk.rkh.doc(title = rk.rkh.title("Posit R Markdown Cheat Sheet"), summary = rk.rkh.summary("All essential elements from the RStudio Cheat Sheet."))

  c2_type <- rk.XML.dropdown("Select element to generate:", options = list(
    "--- TEXT FORMATTING ---"           = list(val = "none1"),
    "[Text] Headers (H1, H2, H3)"       = list(val = "headers", chk = TRUE),
    "[Text] Styles (Bold, Italic)"      = list(val = "styles"),
    "[Text] Lists (Bullets & Numbers)"  = list(val = "lists"),
    "[Text] Links & Footnotes"          = list(val = "links"),
    "[Text] Math Equations"             = list(val = "math"),
    "--- CODE CHUNKS ---"               = list(val = "none2"),
    "[Code] Basic Chunk"                = list(val = "chunk_basic"),
    "[Code] Silent Chunk (Hidden)"      = list(val = "chunk_hidden"),
    "[Code] Plot/Figure Chunk"          = list(val = "chunk_plot"),
    "[Code] Inline Code"                = list(val = "chunk_inline"),
    "--- TABLES ---"                    = list(val = "none3"),
    "[Table] Native Markdown Table"     = list(val = "tbl_md"),
    "[Table] knitr::kable() Table"      = list(val = "tbl_kable")
  ), id.name = "c2_type")

  dialog_snip <- rk.XML.dialog(label = "R Markdown Cheat Sheet", child = rk.XML.row(rk.XML.col(rk.XML.text("Based on the official RStudio/Posit Cheat Sheet."), c2_type, rk.XML.stretch())))

  js_calc_snip <- "
    var type = getValue('c2_type');
    echo('snippet <- c(\\n');
    if (type == 'headers') {
      echo('  \"# Header 1\",\\n  \"## Header 2\",\\n  \"### Header 3\",\\n  \"#### Header 4\"\\n');
    } else if (type == 'styles') {
      echo('  \"**Bold Text**\",\\n  \"*Italic Text*\",\\n  \"~~Strikethrough~~\",\\n  \"Superscript^2^\",\\n  \"Subscript~2~\"\\n');
    } else if (type == 'lists') {
      echo('  \"* Unordered list item\",\\n  \"  * Sub-item (two spaces)\",\\n  \"  * Another sub-item\",\\n  \"\",\\n');
      echo('  \"1. Ordered item one\",\\n  \"2. Ordered item two\",\\n  \"    + Ordered sub-item (four spaces)\"\\n');
    } else if (type == 'links') {
      echo('  \"[Link text](https://posit.co)\",\\n  \"\",\\n  \"![Image caption](path/to/image.png)\",\\n  \"\",\\n  \"Normal text with a footnote.^[This is the footnote text.]\"\\n');
    } else if (type == 'math') {
      echo('  \"Inline equation: $A = \\\\\\\\pi r^2$\",\\n  \"\",\\n  \"Block equation:\",\\n  \"$$\",\\n  \"y_i = \\\\\\\\beta_0 + \\\\\\\\beta_1 x_i + \\\\\\\\epsilon_i\",\\n  \"$$\"\\n');
    } else if (type == 'chunk_basic') {
      echo('  \"```{r chunk_name}\",\\n  \"# Your R code here\",\\n  \"summary(cars)\",\\n  \"```\"\\n');
    } else if (type == 'chunk_hidden') {
      echo('  \"```{r hidden_chunk, echo=FALSE, results=\\'hide\\', message=FALSE, warning=FALSE}\",\\n  \"# Code runs but no output is printed in the document\",\\n  \"x <- 1 + 1\",\\n  \"```\"\\n');
    } else if (type == 'chunk_plot') {
      echo('  \"```{r my_plot, fig.width=6, fig.height=4, fig.align=\\'center\\', fig.cap=\\'This is the figure caption\\'}\",\\n  \"plot(cars)\",\\n  \"```\"\\n');
    } else if (type == 'chunk_inline') {
      echo('  \"The code is evaluated directly within the text.\",\\n  \"\",\\n  \"Today is `r Sys.Date()` and there are `r nrow(cars)` observations in the dataset.\"\\n');
    } else if (type == 'tbl_md') {
      echo('  \"| Column 1 | Column 2 | Column 3 |\",\\n  \"|:---------|:--------:|---------:|\",\\n  \"| Left     | Center   | Right    |\",\\n  \"| Data 1   | Data 2   | Data 3   |\"\\n');
    } else if (type == 'tbl_kable') {
      echo('  \"```{r kable_table}\",\\n  \"# Requires the knitr package\",\\n  \"knitr::kable(head(mtcars), digits = 2, caption = \\'Table generated by knitr\\')\",\\n  \"```\"\\n');
    } else {
      echo('  \"# Please select a valid option from the menu.\"\\n');
    }
    echo(')\\n');
  "

  js_print_snip <- "
    echo('rk.header(\"Cheat Sheet Snippet\", level=2)\\n');
    echo('cat(\"\\\\n------------------------------------------------------------\\\\n\")\\n');
    echo('cat(paste(snippet, collapse=\"\\\\n\"))\\n');
    echo('cat(\"\\\\n------------------------------------------------------------\\\\n\\\\n\")\\n');
  "
  comp_snip <- rk.plugin.component("2. Markdown Cheat Sheet", xml = list(dialog = dialog_snip), js = list(calculate = js_calc_snip, printout = js_print_snip), hierarchy = common_hierarchy, rkh = list(help = help_snip))

  # =========================================================================================
  # SUB-COMPONENT 3: APA Manuscript Builder (papaja)
  # =========================================================================================
  help_papaja <- rk.rkh.doc(title = rk.rkh.title("APA papaja Builder"), summary = rk.rkh.summary("Advanced builder for APA 6th/7th edition manuscripts."))

  c3_title      <- rk.XML.input("Manuscript Title", initial = "The Title of the Paper", required = TRUE, id.name = "c3_title")
  c3_shorttitle <- rk.XML.input("Running Head (Short Title)", initial = "SHORT TITLE", required = TRUE, id.name = "c3_shorttitle")
  c3_abstract   <- rk.XML.input("Abstract (Multiple lines allowed)", initial = "Enter abstract here...", size = "large", id.name = "c3_abstract")
  c3_keywords   <- rk.XML.input("Keywords (comma separated)", initial = "keyword 1, keyword 2", id.name = "c3_keywords")

  c3_affil_mat  <- rk.XML.matrix("1. Define Affiliations", rows = 1, columns = 2, min = 1, mode = "string", fixed_width = FALSE, horiz_headers = c("ID (e.g., '1')", "Institution Name"), id.name = "c3_affil_mat")
  c3_author_mat <- rk.XML.matrix("2. Define Authors", rows = 1, columns = 4, min = 1, mode = "string", fixed_width = FALSE, horiz_headers = c("Full Name", "Affil. IDs (e.g., '1' or '1,2')", "Corresponding? (yes/no)", "Email"), id.name = "c3_author_mat")

  c3_class      <- rk.XML.dropdown("APA Edition", options = list("APA 6th Edition" = list(val = "apa6"), "APA 7th Edition" = list(val = "apa7", chk = TRUE)), id.name = "c3_class")
  c3_format     <- rk.XML.dropdown("Output Format", options = list("PDF (LaTeX required)" = list(val = "papaja::apa6_pdf", chk = TRUE), "Word Document" = list(val = "papaja::apa6_word")), id.name = "c3_format")

  c3_floats   <- rk.XML.cbox("Integrate tables and figures in text (floatsintext)", value = "TRUE", chk = TRUE, id.name = "c3_floats")
  c3_mask     <- rk.XML.cbox("Masked for Peer Review (hides authors)", value = "TRUE", chk = FALSE, id.name = "c3_mask")
  c3_linenum  <- rk.XML.cbox("Show Line Numbers", value = "TRUE", chk = FALSE, id.name = "c3_linenum")

  c3_save_opt <- rk.XML.browser("Optional: Save to .Rmd file", type = "savefile", required = FALSE, id.name = "c3_save_opt")

  tab_c3_info   <- rk.XML.col(c3_title, c3_shorttitle, c3_abstract, c3_keywords)
  tab_c3_author <- rk.XML.col(rk.XML.text("<i>First, define institutions with an ID. Then assign those IDs to authors.</i>"), c3_affil_mat, c3_author_mat)
  tab_c3_opts   <- rk.XML.col(rk.XML.frame(c3_class, c3_format, label="Format"), rk.XML.frame(c3_floats, c3_mask, c3_linenum, label="Manuscript Options"))
  tab_c3_out    <- rk.XML.col(c3_save_opt)

  dialog_papaja <- rk.XML.dialog(label = "APA Manuscript (papaja)", child = rk.XML.tabbook(tabs = list("Title & Abstract" = tab_c3_info, "Authors" = tab_c3_author, "Settings" = tab_c3_opts, "Export" = tab_c3_out)))

  js_calc_papaja <- paste0(js_sanitize_input, "
    var title = cleanStr(getValue('c3_title'));
    var shorttitle = cleanStr(getValue('c3_shorttitle'));
    var abstract = cleanStr(getValue('c3_abstract'));
    var keywords = cleanStr(getValue('c3_keywords'));
    var doc_class = getValue('c3_class');
    var format = getValue('c3_format');
    var is_floats = getValue('c3_floats') == 'TRUE';
    var is_mask = getValue('c3_mask') == 'TRUE';
    var is_linenum = getValue('c3_linenum') == 'TRUE';

    echo('p_meta <- list()\\n');
    echo('p_meta$title <- \"' + title + '\"\\n');
    echo('p_meta$shorttitle <- \"' + shorttitle + '\"\\n');

    echo('author_mat <- ' + getValue('c3_author_mat') + '\\n');
    echo('if (is.matrix(author_mat) && nrow(author_mat) > 0) {\\n');
    echo('  author_mat <- author_mat[author_mat[,1] != \"\", , drop = FALSE]\\n');
    echo('  if (nrow(author_mat) > 0) {\\n');
    echo('    p_meta$author <- lapply(1:nrow(author_mat), function(i) {\\n');
    echo('      list(\\n');
    echo('        name = author_mat[i, 1],\\n');
    echo('        affiliation = as.character(trimws(unlist(strsplit(author_mat[i, 2], \",\")))),\\n');
    echo('        corresponding = tolower(trimws(author_mat[i, 3])) %in% c(\"yes\", \"y\", \"true\", \"1\"),\\n');
    echo('        email = author_mat[i, 4]\\n');
    echo('      )\\n');
    echo('    })\\n');
    echo('  }\\n');
    echo('}\\n');

    echo('affil_mat <- ' + getValue('c3_affil_mat') + '\\n');
    echo('if (is.matrix(affil_mat) && nrow(affil_mat) > 0) {\\n');
    echo('  affil_mat <- affil_mat[affil_mat[,1] != \"\", , drop = FALSE]\\n');
    echo('  if (nrow(affil_mat) > 0) {\\n');
    echo('    p_meta$affiliation <- lapply(1:nrow(affil_mat), function(i) {\\n');
    echo('      list(id = affil_mat[i, 1], institution = affil_mat[i, 2])\\n');
    echo('    })\\n');
    echo('  }\\n');
    echo('}\\n');

    if (abstract != '') echo('p_meta$abstract <- \"' + abstract + '\"\\n');
    if (keywords != '') echo('p_meta$keywords <- \"' + keywords + '\"\\n');
    echo('p_meta$wordcount <- \"X\"\\n');
    echo('p_meta$bibliography <- c(\"r-references.bib\")\\n');

    if (is_floats) echo('p_meta$floatsintext <- TRUE\\n');
    if (is_mask) echo('p_meta$mask <- TRUE\\n');
    if (is_linenum) echo('p_meta$linenumbers <- TRUE\\n');

    echo('p_meta$figurelist <- FALSE\\n');
    echo('p_meta$tablelist <- FALSE\\n');
    echo('p_meta$footnotelist <- FALSE\\n');

    echo('p_meta$documentclass <- \"' + doc_class + '\"\\n');
    echo('p_meta$output <- \"' + format + '\"\\n');

    echo('yaml_str <- yaml::as.yaml(p_meta)\\n');
    echo('full_papaja <- paste0(\"---\\\\n\", yaml_str, \"---\\\\n\\\\n```{r setup, include = FALSE}\\\\nlibrary(\\\"papaja\\\")\\\\nr_refs(\\\"r-references.bib\\\")\\\\n```\\\\n\\\\n# Methods\\\\nWe report how we determined our sample size...\\\\n\")\\n');
  ")

  js_print_papaja <- "
    var savefile = getValue('c3_save_opt');
    echo('rk.header(\"Generated papaja Manuscript Code\", level=2)\\n');
    echo('cat(\"\\\\n============================================================\\\\n\")\\n');
    echo('cat(full_papaja)\\n');
    echo('cat(\"============================================================\\\\n\\\\n\")\\n');

    if (savefile != '') {
        echo('save_path <- \"' + savefile + '\"\\n');
        echo('if (!grepl(\"\\\\\\\\.Rmd$\", save_path, ignore.case = TRUE)) { save_path <- paste0(save_path, \".Rmd\") }\\n');
        echo('writeLines(full_papaja, con = save_path)\\n');
        echo('rk.print(paste(\"papaja file successfully saved to:\", save_path))\\n');
    }
  "

  comp_papaja <- rk.plugin.component("3. APA Manuscript (papaja)", xml = list(dialog = dialog_papaja), js = list(require = c("yaml"), calculate = js_calc_papaja, printout = js_print_papaja), hierarchy = common_hierarchy, rkh = list(help = help_papaja))


  # =========================================================================================
  # ASSEMBLE SKELETON
  # =========================================================================================

  # NOTE THE UPDATED PLUGINMAP NAME!
  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_std),
    js = list(require = c("yaml"), calculate = js_calc_std, printout = js_print_std),
    rkh = list(help = help_std),
    components = list(comp_snip, comp_papaja),
    pluginmap = list(name = "1. Document Builder (Standard & General Templates)", hierarchy = common_hierarchy),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  # -----------------------------------------------------------------------------------------
  # TRANSLATION GENERATOR FOR MULTIPLE LANGUAGES
  # Generates .po files for Spanish, German, French, and Brazilian Portuguese
  # -----------------------------------------------------------------------------------------
  tryCatch({
    rk.updatePluginMessages("rk.rmd", c("es", "de", "fr", "pt_BR"))
    cat("\nSUCCESS: Translation (.po) files generated for es, de, fr, pt_BR.\n")
    cat("Look inside the folder: ", file.path(getwd(), "rk.rmd", "po"), "\n")
  }, error = function(e) {
    message("\nWARNING: Could not extract .po files automatically.")
    message("You must install the 'gettext' tools on your Linux system first.")
    message("Open Konsole and run:  sudo apt install gettext")
    message("Then run this R script again.")
  })

  cat("\nPlugin successfully generated.\n")
})
