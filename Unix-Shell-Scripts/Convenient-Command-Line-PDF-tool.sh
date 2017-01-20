## Installation and usage of command-line tool, `pdftk`
## David Chen

## Installation
brew install poppler ## make sure to have updated Xcode
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


## Convenient tool to convert PDF to PNG (or other file formats)
## with easy controls (e.g. resolution)
brew install ImageMagick
convert --help
## Define resolutions and convert:
convert -density 300 -quality 100 testFile.pdf testFile.png #300dpi

## Select a specific page. For example, page 2 of 2:
## IMPORTANT: Index starts at ZERO!
convert -density 300 -quality 100 testFile.pdf.pdf[1] image.jpg
## Multiple pages will be supported; each separated by ""-PAGE_NUM"
convert -density 300 -quality 100 testFile.pdf.pdf[2,5,11] pages.jpg
ls
# pages-2.png
# pages-4.png
