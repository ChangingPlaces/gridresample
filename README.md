# gridresample
Grid Resample takes GIS data and distributes it over a bucket grid.

## running

1. Open in processing
1. Click the run button.

## customization

* Put your favorite shapefile in the data directory. (some are available at [census.gov](https://www.census.gov/geo/maps-data/data/tiger-data.html))
* Change the value of the ``shapefile_filename`` variable to your shapefile.
* Change the value of the ``property_name`` variable to the shapfile property name you want to visualize.

## interaction

* ``a``,``d`` keys: decrease, increase number of columns.
* ``s``,``w`` keys: decrease, increase number of rows.
* ``q``,``w`` keys: rotate grid left and right
* ``-``,``+`` keys: decrease, increase size of grid cells
* ``mouse click``: recenter grid
