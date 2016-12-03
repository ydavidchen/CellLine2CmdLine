# Resources for analyzing and visualizing bench experiments in the informatics space

## Overview:

Welcome! This repository is intended for storing code and pointing to external resources for analyzing and/or visualizing experimental data in the life sciences. Examples include:

* Reading and visualizing DNA fragment data files (instrument) into R;
* Visualizing pyrosequencing data in R;
* Genomic data visualization in R with example data sets;

We aim to provide resources to better translate bench-top results to computer data. In particular, we try to bridge the gap in tools that are currently lacking or requires improvement.

In individual scripts, please note relevant references, which may include the names of software packages used/dependent upon and journal articles reporting the software. We thank programmers and developers who distributed their software packages.

Tutorials may be written in R Markdown (.rmd) and/or LaTex (.tex).

While the programming language is R, tools based in other languages such as UNIX, Python, and C may be included in the future.

## Bioinformatics workflows for common bench experiments that are well-documented:

### General tools:

* Analysis of flow-cytometry data using the [`flowCore` R/Bioconductor pakcage] (https://bioconductor.org/packages/release/bioc/html/flowCore.html)
* Analysis of quantitative polymerase chain reaction (qPCR) in R: [qpcR] (https://cran.r-project.org/web/packages/qpcR/index.html), [HTqPCR] (https://www.bioconductor.org/packages/release/bioc/html/HTqPCR.html), [EasyqPCR] (https://www.bioconductor.org/packages/release/bioc/html/EasyqpcR.html)
* Analysis of [dose response curve in R] (https://cran.r-project.org/web/packages/drc/index.html)

### Specific computational tools:

* [PAM50 gene list and sample R code by J.S. Parker (J Clin. Oncol. 2009; zipped folder)] (https://genome.unc.edu/pubsup/breastGEO/PAM50.zip)

## Other resources:

* [GitHub pages](https://pages.github.com/)
* [Good coding styles (courtesy of M. Steinbaugh)] (http://steinbaugh.com/guides/programming_style)

## Coming soon:

* Genomic data visualization using the `Gviz` R/Bioconductor package
* Reproducible preparation of multiplex ligation-dependent probe amplification training data set in R (original tutorial was in Excel)
