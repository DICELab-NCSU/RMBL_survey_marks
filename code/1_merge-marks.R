##################################################-
## Merge local benchmark points ----
## W.K. Petry
##################################################-
## Preliminaries ----
##################################################-
library(tidyverse)
library(sf)
library(lubridate)

theme_set(theme_bw(base_size = 18)+
            theme(panel.grid = element_blank(),
            plot.margin = margin(10, 25, 10, 10),
            axis.text = element_text(color = "black"),
            axis.ticks = element_line(linewidth = 0.5)))

##################################################-
## Read in point data ----
##################################################-
# GOTHIC_LOCAL06
gothic_local06 <- read_sf("raw-marks/GOTHIC_LOCAL06/GOTHIC_LOCAL06.shp") |>
  st_zm() |>
  select(name = ObjName, geometry) |>
  mutate(name = paste("Gothic", name),
         installed = 2005L,
         installer = "RMBL / J Boynton",
         type = NA_character_,
         position_quality = "SINGLE",
         stability = NA_character_,
         condition = NA_character_)

# MEXCUT_MON
mexcut_mon <- read_sf("raw-marks/MEXCUT_MON/MEXCUT_MON.shp") |>
  st_zm() |>
  filter(MONUMENT == "YES",
         str_detect(ObjName, "GPS")) |>
  select(name = ObjName, geometry) |>
  mutate(name = paste("MexCut", name),
         installed = 2005L,
         installer = "RMBL / J Boynton",
         type = NA_character_,
         position_quality = "SINGLE",
         stability = NA_character_,
         condition = NA_character_)

# PETRY
petry <- read_csv("raw-marks/PETRY/Survey Marks.csv") |>
  drop_na(Longitude, Latitude) |>
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) |>
  rename(name = Name) |>
  filter(!str_detect(name, "^TEMP")) |>
  arrange(name, `Lateral RMS`) |>
  group_by(name) |>
  slice(1) |>
  ungroup() |>
  mutate(installed = year(ymd_hms(`Averaging start`)),
         installer = "W Petry",
         type = "magnail in bedrock",
         position_quality = case_when(
           `Solution status` == "FIX" ~ "FIX",
           `Solution status` == "SINGLE" ~ "SINGLE"
         ),
         stability = "high",
         condition = "good") %>%
  select(name, installed, installer, type, position_quality, stability, geometry)

##################################################-
## Merge & unify metadata ----
##################################################-
current_monuments <- list(petry, mexcut_mon, gothic_local06) %>%
  do.call(bind_rows, .) %>%
  mutate(coords = st_coordinates(.),
         lat_dd = unname(coords[,2]),
         lon_dd = unname(coords[,1])) %>%
  select(-coords) %>%
  st_transform(crs = 32613) # metric projection, matches DEM

ggplot(current_monuments)+
  geom_sf()

##################################################-
## Update metadata using recoveries ----
##################################################-
recover <- read_csv("recoveries/recovery_log.csv")
recover_latest <- recover |>
  group_by(mark_name) |>
  arrange(mark_name, recovery_date) |>
  slice(1) |>
  ungroup()

current_monuments_recover <- current_monuments %>%
  left_join(recover_latest, by = c("name" = "mark_name"), suffix = c("", ".y")) %>%
  mutate(type = coalesce(type, type.y),
         stability = coalesce(stability, stability.y),
         condition = coalesce(condition, condition.y)) %>%
  select(name, installed, installer, type, position_quality, lat_dd, lon_dd,
         latest_recovery = recovery_date, recovered_by, found_mark, stability, condition,
         geometry)

##################################################-
## Write out ----
##################################################-
# current release (main directory)
write_sf(current_monuments_recover, "current_mark-points.geojson", append = FALSE)

# archive copy
cyear <- year(today())
cvers <- 1
dir.create(paste0("old_releases/", cyear))
write_sf(current_monuments_recover, paste0("old_releases/", cyear, "/", cyear, ".", cvers,
                                   "_mark-points.geojson"),
         append = FALSE)

aoi <- st_buffer(current_monuments, dist = 10000) %>%
  st_bbox() %>%
  st_as_sfc()
write_sf(aoi, "utilities/AOI.geojson", append = FALSE)
write_sf(aoi, "utilities/AOI.shp", append = FALSE)

##################################################-
## Rename viewshed rasters ----
##################################################-
# for(i in 1:nrow(current_monuments_recover)){
#   old <- paste0("raw-viewsheds/viewshed_8km_", i - 1, ".tif")
#   new <- paste0("raw-viewsheds/", current_monuments_recover$name[i], "-8km.tif")
#   file.rename(from = old, to = new)
# }
