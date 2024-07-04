##################################################-
## Make viewsheds ----
## W.K. Petry
##################################################-
## Preliminaries ----
##################################################-
library(tidyverse)
library(sf)
library(terra)
library(viewscape)
library(tidyterra)
library(parallel)

theme_set(theme_bw(base_size = 18)+
            theme(panel.grid = element_blank(),
            plot.margin = margin(10, 25, 10, 10),
            axis.text = element_text(color = "black"),
            axis.ticks = element_line(linewidth = 0.5),
            strip.background = element_blank(),
            strip.text = element_text(size = 20, face = "bold")))

##################################################-
## Load spatial data ----
##################################################-
marks <- read_sf("current_mark-points.geojson")
dem <- rast("elevation/dem_aoi.tif")

ggplot()+
  geom_spatraster(data = dem)+
  scale_fill_whitebox_c("high_relief")

##################################################-
## Calculate viewsheds ----
##################################################-
# 8km antenna range
vs_8km <- compute_viewshed(dsm = dem, viewpoints = marks,
                           offset_viewpoint = 2, offset_height = 2,
                           r = 8000, parallel = TRUE, workers = 8)
names(vs_8km) <- marks$name

vs_poly_8km <- mclapply(vs_8km, visualize_viewshed, outputtype = "polygon",
                 mc.cores = 8) |>
  bind_rows(.id = "name") |>
  select(-lyr.1) |>
  st_transform(crs = 32613)

st_write(vs_poly_8km, "current_mark-viewsheds-8km.geojson")

# 11km antenna range
vs_11km <- compute_viewshed(dsm = dem, viewpoints = marks,
                           offset_viewpoint = 2, offset_height = 2,
                           r = 11000, parallel = TRUE, workers = 8)
names(vs_11km) <- marks$name

vs_poly_11km <- mclapply(vs_11km, visualize_viewshed, outputtype = "polygon",
                         mc.cores = 8) |>
  bind_rows(.id = "name") |>
  select(-lyr.1) |>
  st_transform(crs = 32613)

st_write(vs_poly_11km, "current_mark-viewsheds-11km.geojson")
