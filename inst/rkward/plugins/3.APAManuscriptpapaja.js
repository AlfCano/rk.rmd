// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(yaml)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function cleanStr(val) {
        if(!val) return '';
        return val.replace(/'/g, "\\'").replace(/"/g, '\\"').replace(/\n/g, '\\n');
    }
  
    var title = cleanStr(getValue('c3_title'));
    var shorttitle = cleanStr(getValue('c3_shorttitle'));
    var abstract = cleanStr(getValue('c3_abstract'));
    var keywords = cleanStr(getValue('c3_keywords'));
    var doc_class = getValue('c3_class');
    var format = getValue('c3_format');
    var is_floats = getValue('c3_floats') == 'TRUE';
    var is_mask = getValue('c3_mask') == 'TRUE';
    var is_linenum = getValue('c3_linenum') == 'TRUE';

    echo('p_meta <- list()\n');
    echo('p_meta$title <- "' + title + '"\n');
    echo('p_meta$shorttitle <- "' + shorttitle + '"\n');

    echo('author_mat <- ' + getValue('c3_author_mat') + '\n');
    echo('if (is.matrix(author_mat) && nrow(author_mat) > 0) {\n');
    echo('  author_mat <- author_mat[author_mat[,1] != "", , drop = FALSE]\n');
    echo('  if (nrow(author_mat) > 0) {\n');
    echo('    p_meta$author <- lapply(1:nrow(author_mat), function(i) {\n');
    echo('      list(\n');
    echo('        name = author_mat[i, 1],\n');
    echo('        affiliation = as.character(trimws(unlist(strsplit(author_mat[i, 2], ",")))),\n');
    echo('        corresponding = tolower(trimws(author_mat[i, 3])) %in% c("yes", "y", "true", "1"),\n');
    echo('        email = author_mat[i, 4]\n');
    echo('      )\n');
    echo('    })\n');
    echo('  }\n');
    echo('}\n');

    echo('affil_mat <- ' + getValue('c3_affil_mat') + '\n');
    echo('if (is.matrix(affil_mat) && nrow(affil_mat) > 0) {\n');
    echo('  affil_mat <- affil_mat[affil_mat[,1] != "", , drop = FALSE]\n');
    echo('  if (nrow(affil_mat) > 0) {\n');
    echo('    p_meta$affiliation <- lapply(1:nrow(affil_mat), function(i) {\n');
    echo('      list(id = affil_mat[i, 1], institution = affil_mat[i, 2])\n');
    echo('    })\n');
    echo('  }\n');
    echo('}\n');

    if (abstract != '') echo('p_meta$abstract <- "' + abstract + '"\n');
    if (keywords != '') echo('p_meta$keywords <- "' + keywords + '"\n');
    echo('p_meta$wordcount <- "X"\n');
    echo('p_meta$bibliography <- c("r-references.bib")\n');

    if (is_floats) echo('p_meta$floatsintext <- TRUE\n');
    if (is_mask) echo('p_meta$mask <- TRUE\n');
    if (is_linenum) echo('p_meta$linenumbers <- TRUE\n');

    echo('p_meta$figurelist <- FALSE\n');
    echo('p_meta$tablelist <- FALSE\n');
    echo('p_meta$footnotelist <- FALSE\n');

    echo('p_meta$documentclass <- "' + doc_class + '"\n');
    echo('p_meta$output <- "' + format + '"\n');

    echo('yaml_str <- yaml::as.yaml(p_meta)\n');
    echo('full_papaja <- paste0("---\\n", yaml_str, "---\\n\\n```{r setup, include = FALSE}\\nlibrary(\"papaja\")\\nr_refs(\"r-references.bib\")\\n```\\n\\n# Methods\\nWe report how we determined our sample size...\\n")\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("3. APA Manuscript (papaja) results")).print();

    var savefile = getValue('c3_save_opt');
    echo('rk.header("Generated papaja Manuscript Code", level=2)\n');
    echo('cat("\\n============================================================\\n")\n');
    echo('cat(full_papaja)\n');
    echo('cat("============================================================\\n\\n")\n');

    if (savefile != '') {
        echo('save_path <- "' + savefile + '"\n');
        echo('if (!grepl("\\\\.Rmd$", save_path, ignore.case = TRUE)) { save_path <- paste0(save_path, ".Rmd") }\n');
        echo('writeLines(full_papaja, con = save_path)\n');
        echo('rk.print(paste("papaja file successfully saved to:", save_path))\n');
    }
  

}

