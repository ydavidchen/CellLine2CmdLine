## RCircos Demo with custom settings
## Date: August 23, 2017
## Package versions: RColorBrewer_1.1-2, RCircos_1.2.0  
## You're encourage to learn this package by reading its very well-written Vignette!

rm(list=ls())
library(RCircos)
library(RColorBrewer)
data("UCSC.HG19.Human.CytoBandIdeogram");

#--------------------------------------Custom settings--------------------------------------
## After running the line below, a pop-u pwindow 
fixInNamespace("RCircos.Get.Heatmap.Color.Scale", "RCircos")
## DO NOT RUN the following but copy and paste the following into the pop-up window triggered by `fixInNamespace`:
if(is.null(heatmap.color)) stop("Missing argument in RCircos.Get.Heatmap.Color.Scale().\n")
n.color <- 1024; #defaults to more colors
allOnes  <- seq(1, 1, length = n.color);
allZeros <- seq(0, 0, length = n.color);
one2zeor <- seq(1, 0, length = n.color);
zero2one <- seq(0, 1, length = n.color);
if (heatmap.color == "BlueWhiteRed") {
  RedRamp <- rgb(allOnes, one2zeor, one2zeor)
  BlueRamp <- rgb(zero2one, zero2one, allOnes)
  ColorRamp <- cbind(BlueRamp, RedRamp)
} else if (heatmap.color == "GreenWhiteRed") {
  RedRamp <- rgb(allOnes, one2zeor, one2zeor)
  GreenRamp <- rgb(zero2one, allOnes, zero2one)
  ColorRamp <- cbind(GreenRamp, RedRamp)
} else if (heatmap.color == "YellowBlue") {
  require(RColorBrewer);
  colfunc <- colorRampPalette(c("yellow", "blue"));
  ColorRamp <- colfunc(n.color);
} else if (heatmap.color == "GreenYellowRed") {
  RedRamp <- rgb(allOnes, one2zeor, allZeros)
  GreenRamp <- rgb(zero2one, allOnes, allZeros)
  ColorRamp <- cbind(GreenRamp, RedRamp)
} else if (heatmap.color == "GreenBlackRed") {
  RedRamp <- rgb(zero2one, allZeros, allZeros)
  GreenRamp <- rgb(allZeros, one2zeor, allZeros)
  ColorRamp <- cbind(GreenRamp, RedRamp)
} else if (heatmap.color == "YellowToRed") {
  ColorRamp <- rgb(allOnes, one2zeor, allZeros)
} else {
  ColorRamp <- rgb(one2zeor, one2zeor, one2zeor)
}
return(ColorRamp)
## END

fixInNamespace("RCircos.Validate.Plot.Parameters", "RCircos"); 
## Copy the following into the line 11 of pop-up:
heatmapColors <- c(RCircos.Get.Supported.HeatmapColors(),"YellowBlue"); 
## END

## Set corecomponents:
RCircos.Set.Core.Components(UCSC.HG19.Human.CytoBandIdeogram,tracks.inside=10, tracks.outside=5);
RCircos.Get.Plot.Parameters()

## Retrieve & reset parameters: 
RC.param <- RCircos.Get.Plot.Parameters(); 
if(! is.null(RC.param) ){
  print("Proceed to parameter resetting...")
  ## Reset to custom, unsuported heat map color:
  RC.param['heatmap.color'] <- "YellowBlue";
  
  ## Set dot plot background color: 
  RC.param['track.background'] <- "white";
} else {
  stop("Failed to reset because graphical parameters have not been (properly) initialized!")
}

## Complete resetting (required to take effect):
RCircos.Reset.Plot.Parameters(new.params=RC.param); 
RCircos.Get.Plot.Parameters() #check

#--------------------------------------Layer by layer plotting--------------------------------------
## Step0: Load the required built-in data sets:
data("RCircos.Gene.Label.Data"); 
data("RCircos.Heatmap.Data");
data("RCircos.Scatter.Data");
data("RCircos.Line.Data");
data("RCircos.Histogram.Data");
data("RCircos.Tile.Data");
data("RCircos.Link.Data");
data("RCircos.Ribbon.Data");

## Step1. Initialize graphic device:
RCircos.Set.Plot.Area();
## Step2. Plot chromosome ideogram:
RCircos.Draw.Chromosome.Ideogram(ideo.pos=NULL, ideo.width=NULL);
RCircos.Label.Chromosome.Names(chr.name.pos=NULL);
## Step3. Gene labels
RCircos.Gene.Connector.Plot(RCircos.Gene.Label.Data,track.num=1,side="out",outside.pos=1);
RCircos.Gene.Name.Plot(RCircos.Gene.Label.Data, name.col=4, track.num=2, side="out",outside.pos=3);
RCircos.Get.Gene.Name.Plot.Parameters() #see num labels for ea chr

## Step4. Add heat map, histogram, line/scatter/tile plots as tracks:
## 4a. Heat map with custom color scale:
RCircos.Heatmap.Plot(RCircos.Heatmap.Data,data.col=6,track.num=2,side="in"); 
## 4b. Scatterplot:
RCircos.Scatter.Data$chromosome <- paste0("chr", RCircos.Scatter.Data$chromosome); #required to resolve
RCircos.Scatter.Plot(RCircos.Scatter.Data,data.col=5,track.num=6,side="in",by.fold=1); 
## 4c. Line plot:
RCircos.Line.Data$chromosome <- paste0("chr",RCircos.Line.Data$chromosome); #required to resolve
RCircos.Line.Plot(RCircos.Line.Data, data.col=5, track.num=7, side="in");
## 4d. Histogram:
RCircos.Histogram.Plot(RCircos.Histogram.Data, data.col=4, track.num=8, side="in");
## 4e. Tile:
RCircos.Tile.Plot(RCircos.Tile.Data, track.num=9, side="in"); 

## Add connections
## 5a. Links:
RCircos.Link.Plot(RCircos.Link.Data ,track.num=11, TRUE); #skip a track, since 
## 5b. Ribbons
RCircos.Ribbon.Plot(RCircos.Ribbon.Data,track.num=11, by.chromosome=F, twist=F); 
dev.off()
