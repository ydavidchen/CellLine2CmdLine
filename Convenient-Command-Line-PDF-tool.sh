# Installation and usage of command-line tool, `pdftk`
# David Chen

## Installation
brew install poppler
gem install pdfunite

## Verify installed software:
gem search ^pdfunite
## *** REMOTE GEMS ***
## pdfunite (0.3.0)

## Example: To merge file1.pdf and file2.pdf in my Downloads folder:
cd ~/Downloads/
pdfunite -h #check how to type the syntax
## Usage: pdfunite [options] <PDF-sourcefile-1>..<PDF-sourcefile-n> <PDF-destfile>
pdfunite file1.pdf file2.pdf compiled.pdf
