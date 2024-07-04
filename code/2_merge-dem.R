##################################################-
## Fetch & merge DEM tiles ----
## W.K. Petry
##################################################-
## Preliminaries ----
##################################################-
library(tidyverse)
library(sf)
library(terra)
library(tidyterra)

theme_set(theme_bw(base_size = 18)+
            theme(panel.grid = element_blank(),
            plot.margin = margin(10, 25, 10, 10),
            axis.text = element_text(color = "black"),
            axis.ticks = element_line(linewidth = 0.5),
            strip.background = element_blank(),
            strip.text = element_text(size = 20, face = "bold")))

options(timeout = max(500, getOption("timeout")))

##################################################-
## Load AOI ----
##################################################-
aoi <- read_sf("utilities/AOI.geojson")

##################################################-
## Download USGS 1/3 arcsec DEM rasters ----
##################################################-
prefix <- "https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/TIFF/historical/"
files <- c("USGS_13_n39w107_20220331.tif", "USGS_13_n39w108_20220720.tif",
           "USGS_13_n40w107_20220216.tif", "USGS_13_n40w108_20211208.tif")
urls <- paste0(prefix, str_extract(files, "^USGS_13_(.+)_[0-9]+.tif$", group = 1), "/", files)

if(any(!file.exists(paste0("elevation/", files)))) {
  for(i in 1:length(files)) {
    download.file(url = urls[i], destfile = paste0("elevation/", files[i]))
  }
}

##################################################-
## Load, merge, warp, write out raster ----
##################################################-
dem_files <- list.files(path = "elevation", pattern = "^USGS.*\\.tif$", full.names = TRUE)
dem_merged <- lapply(dem_files, rast) |>
  sprc() |>
  merge() |>
  project("epsg:32613", threads = TRUE) |>
  crop(dem_merged, aoi)

ggplot()+
  geom_spatraster(data = dem_merged)+
  scale_fill_whitebox_c("high_relief")

writeRaster(dem_merged, "elevation/dem_aoi.tif")
