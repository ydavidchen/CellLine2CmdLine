# Resources for analyzing and visualizing biomedical data

## Overview:

Welcome! This repository is intended for storing code and providing external resources for analyzing/visualizing experimental data in biomedical sciences.

**Examples of working with laboratory bench-top data:**

* Visualizing pyrosequencing data using `ggplot2` in R
* Reading and visualizing DNA fragment data files (instrument) into R
* Cleaning up and visualizing enzyme-linked immunosorbent assay (ELISA) data in R
* Calculation of concentrations, volumes, etc. for mass-specrometry proteomics experiments (a reproducible framework alternative to using spreadsheet)

**Example of working with big data:**

* Accessing large-scale (epi)genomics data from
* Genome-scale data visualization using `genomation` R/Bioconductor package
* Single/several-gene-level data visualization using `Gviz` R/Bioconductor package

While the main programming language is R, tools based in other languages such as Unix/Linux, python, and C may be included in the future. Tutorials may also be written in R Markdown (.rmd) or LaTex (.tex).

## General software packages for analyzing laboratory experiments:

* Flow cytometry: [`flowCore`] (https://bioconductor.org/packages/release/bioc/html/flowCore.html), [`flowWorkspace`] (http://www.bioconductor.org/packages/release/bioc/html/flowWorkspace.html), [`ggcyto` (`ggplot2`-based)] (https://bioconductor.riken.jp/packages/3.4/bioc/html/ggcyto.html)
* Quantitative polymerase chain reaction (qPCR) in R: [`qpcR`] (https://cran.r-project.org/web/packages/qpcR/index.html), [`HTqPCR`] (https://www.bioconductor.org/packages/release/bioc/html/HTqPCR.html), [`EasyqPCR`] (https://www.bioconductor.org/packages/release/bioc/html/EasyqpcR.html)
* Dose response curve in R [`DRC`] (https://cran.r-project.org/web/packages/drc/index.html)

## Useful bioinformatics tools:

* [PAM50 gene list and sample R code] (https://genome.unc.edu/pubsup/breastGEO/PAM50.zip) (Parker et al. J Clin. Oncol. 2009; `zip` folder)
* [Estimation of STromal and Immune cells in MAlignant Tumours using Expression data (ESTIMATE)]  (http://bioinformatics.mdanderson.org/main/ESTIMATE:Overview) (Yoshihara et al. Nature Comm. 2013)

## Other resources:

* [Good coding practice for R, python, and shell (courtesy of Dr. M. Steinbaugh)] (http://steinbaugh.com/guides/programming_style)
* [`tableone` R package for generating summary statistics; especially suitable for reporting epidemiological/clinical results] (https://github.com/kaz-yos/tableone/)

## Coming soon:

* Reproducible preparation of multiplex ligation-dependent probe amplification training data set in R (translating instructions for spreadsheet users into R)
