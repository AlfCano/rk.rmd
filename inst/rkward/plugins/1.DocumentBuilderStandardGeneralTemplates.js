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
  
    var title = cleanStr(getValue('c1_title')); var author = cleanStr(getValue('c1_author')); var template = getValue('c1_template');
    var format = getValue('c1_format'); var theme = getValue('c1_theme');
    var hasTOC = getValue('c1_toc') == 'TRUE'; var hasNum = getValue('c1_number') == 'TRUE'; var doDate = getValue('c1_date') == 'TRUE';

    echo('rmd_meta <- list()\n');
    echo('rmd_meta$title <- "' + title + '"\n');
    if (author != '') echo('rmd_meta$author <- "' + author + '"\n');
    if (doDate) echo('rmd_meta$date <- format(Sys.Date(), "%Y-%m-%d")\n');

    if (template == 'standard') {
        echo('fmt_opts <- list()\n');
        if (hasTOC) echo('fmt_opts$toc <- TRUE\n');
        if (hasNum) echo('fmt_opts$number_sections <- TRUE\n');
        if (format == 'html_document' && theme != 'default') echo('fmt_opts$theme <- "' + theme + '"\n');

        echo('rmd_meta$output <- list()\n');
        echo('if(length(fmt_opts) > 0) { rmd_meta$output[["' + format + '"]] <- fmt_opts } else { rmd_meta$output <- "' + format + '" }\n');
    } else {
        echo('rmd_meta$output <- "' + template + '"\n');
        echo('rmd_meta$bibliography <- "references.bib"\n');
    }

    echo('yaml_str <- yaml::as.yaml(rmd_meta)\n');
    echo('full_rmd <- paste0("---\\n", yaml_str, "---\\n\\n```{r setup, include=FALSE}\\nknitr::opts_chunk$set(echo = TRUE)\\n```\\n\\n## Introduction\\n\\nStart writing here...\\n")\n');
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("1. Document Builder (Standard & General Templates) results")).print();

    var savefile = getValue('c1_save_opt');
    echo('rk.header("Generated Document Boilerplate", level=2)\n');
    echo('cat("\\n============================================================\\n")\n');
    echo('cat(full_rmd)\n');
    echo('cat("============================================================\\n\\n")\n');

    if (savefile != '') {
        echo('save_path <- "' + savefile + '"\n');
        echo('if (!grepl("\\\\.Rmd$", save_path, ignore.case = TRUE)) { save_path <- paste0(save_path, ".Rmd") }\n');
        echo('writeLines(full_rmd, con = save_path)\n');
        echo('rk.print(paste("File successfully saved to:", save_path))\n');
    }
  

}

