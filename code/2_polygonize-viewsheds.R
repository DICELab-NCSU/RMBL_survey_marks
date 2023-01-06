##################################################-
## Polygonize binary viewsheds from QGIS ----
## W.K. Petry
##################################################-
## Preliminaries ----
##################################################-
library(tidyverse)

theme_set(theme_bw(base_size = 18)+
            theme(panel.grid = element_blank(),
            plot.margin = margin(10, 25, 10, 10),
            axis.text = element_text(color = "black"),
            axis.ticks = element_line(linewidth = 0.5)))

##################################################-
##  ----
##################################################-
current_viewsheds <- current_monuments %>%
  st_drop_geometry() %>%
  mutate(viewshed_index = 0:(nrow(current_monuments)-1),
         viewshed = map(.x = viewshed_index,
                        .f = ~read_stars(paste0("viewsheds/viewshed_", .x, ".tif")) %>%
                          st_as_sf(., as_points = FALSE, merge = TRUE) %>%
                          `colnames<-`(., c("visible", "geometry")) %>%
                          filter(visible == 1L) %>%
                          select(-visible),
                        .progress = TRUE)) %>%
  select(-viewshed_index) %>%
  unnest(cols = viewshed) %>%
  st_as_sf()

ggplot(test, aes(fill = name))+
  geom_sf()

st_write(current_viewsheds, paste0("release/", year(today()), "mark-viewsheds.geojson"))
