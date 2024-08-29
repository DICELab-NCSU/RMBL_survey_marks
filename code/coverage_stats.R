##################################################-
## Determine RMBL Research Map coverage ----
## W.K. Petry
##################################################-
## Preliminaries ----
##################################################-
library(tidyverse)
library(sf)
library(httr)
library(units)

##################################################-
## Load spatial data ----
##################################################-
# survey mark 8km viewsheds
vs_poly_8km <- st_read("current_mark-viewsheds-8km.geojson")
vs_agg_8km <- st_union(vs_poly_8km)

# RMBL Research Map (query public version)
url <- parse_url("https://services8.arcgis.com/jOS5YDdMN6EQxI1b/arcgis/rest/services")
url$path <- paste(url$path, "ResearchSites_Public_2024/FeatureServer/60/query",
                  sep = "/")
url$query <- list(where = "FID > 0",
                  outFields = "*",
                  returnGeometry = "true",
                  f = "geojson")
request <- build_url(url)

research <- st_read(request, quiet = TRUE) |>
  st_transform(crs = st_crs(vs_poly_8km))

research_agg <- st_union(research)

##################################################-
## Calculate coverage ----
##################################################-
# total area covered by viewsheds
set_units(st_area(vs_agg_8km), "km^2")

# RMBL Research Map percent coverage
100 * st_area(st_intersection(vs_agg_8km, research_agg)) / st_area(research_agg)

##################################################-
## Produce layer of research sites outside of viewshed coverage ----
##################################################-
research_out <- st_difference(research, vs_agg_8km)

st_write(research_out, "~/Downloads/research_out.geojson")
