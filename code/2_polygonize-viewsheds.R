##################################################-
## Polygonize binary viewsheds from QGIS ----
## W.K. Petry
##################################################-
## Preliminaries ----
##################################################-
library(tidyverse)
library(sf)
library(stars)

theme_set(theme_bw(base_size = 18)+
            theme(panel.grid = element_blank(),
            plot.margin = margin(10, 25, 10, 10),
            axis.text = element_text(color = "black"),
            axis.ticks = element_line(linewidth = 0.5)))

##################################################-
## Create viewsheds ----
##################################################-
current_viewsheds <- tibble(file = list.files("raw-viewsheds", pattern = "\\.tif$",
                                              full.names = TRUE)) %>%
  mutate(name = str_extract(file, "\\/(.*)\\.tif", group = 1),
         viewshed = map(.x = file,
                        .f = ~read_stars(.x) %>%
                          st_as_sf(., as_points = FALSE, merge = TRUE) %>%
                          `colnames<-`(., c("visible", "geometry")) %>%
                          filter(visible == 1L) %>%
                          select(-visible),
                        .progress = TRUE)) %>%
  select(-file) %>%
  unnest(cols = viewshed) %>%
  st_as_sf()

ggplot(current_viewsheds, aes(fill = name))+
  geom_sf()

st_write(current_viewsheds, paste0(year(today()), "mark-viewsheds.geojson"))
