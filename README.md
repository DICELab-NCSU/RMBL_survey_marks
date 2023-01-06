# RMBL survey marks for RTK GNSS

## Submit a mark recovery record

## Viewshed analysis
Viewsheds for each survey mark were estimated using the [Visibility Analysis](https://plugins.qgis.org/plugins/ViewshedAnalysis/) v.1.8 plug-in for QGIS v.3.28.2.

### DEM pre-processing
Elevation data were sourced from the [USGS 3DEP 1/3rd arc-second Digital Elevation Models](https://www.sciencebase.gov/catalog/item/4f70aa9fe4b058caae3f8de5). The files required are:

- USGS_13_n39w107_20220331.tif
- USGS_13_n39w108_20220720.tif
- USGS_13_n40w107_20220216.tif
- USGS_13_n40w108_20211208.tif

These files were merged, warped to EPSG:26913, and cropped to the [area of interest](utilities/AOI.geojson) (also available as a Shapefile in [utilities](utilities)). The AOI is defined as the bounding box around the survey marks, each with a 10 km buffer.

### Calculating viewsheds
The interface to the Visibility Analysis plug-in is via the QGIS Toolbox.

#### Create viewpoints > Create viewpoints
Observer location(s): [2023_mark-points](2023_mark-points.geojson)

Digital elevation model: [cropped, warped DEM raster from previous step]

Radius of analysis, meters: 8000 (stock antenna range for [Emlid RS2](https://emlid.com/reachrs2/))

Observer height, meters: 2.0

Target height, meters: 2.0

#### Analysis > Viewshed
Analysis type: Binary viewshed

Observer location(s): [viewpoints from previous step] (tick the 🔁 symbol to generate a separate viewshed for each location)

Digital elevation model: [cropped, warped DEM raster from previous step]

Take into account Earth curvature: ✓

Atmospheric refraction: 0.13

Combining multiple outputs: Addition


