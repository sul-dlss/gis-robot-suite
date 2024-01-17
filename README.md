[![CircleCI](https://circleci.com/gh/sul-dlss/gis-robot-suite.svg?style=svg)](https://circleci.com/gh/sul-dlss/gis-robot-suite)
[![Code Climate](https://codeclimate.com/github/sul-dlss/gis-robot-suite/badges/gpa.svg)](https://codeclimate.com/github/sul-dlss/gis-robot-suite)
[![Code Climate Test Coverage](https://codeclimate.com/github/sul-dlss/gis-robot-suite/badges/coverage.svg)](https://codeclimate.com/github/sul-dlss/)
[![GitHub version](https://badge.fury.io/gh/sul-dlss%2Fgis-robot-suite.svg)](https://badge.fury.io/gh/sul-dlss%2Fgis-robot-suite)

GIS-Robot-Suite
---------------

Robot code for accessioning and delivery of GIS resources.

# Dependencies
These robots require several dependencies needed to perform the GIS workflow steps. These are often shelled out to using `system` calls.

 - [GDAL](https://gdal.org/) Needed for several geospatial tasks. Also needed on servers are the utils and clients
 - `xsltproc` and `xmllint` for transforming XML files
 - rsync also used as part of the robot process and is needed

# Documentation

`gisAssemblyWF`
---------------

* `author-metadata` :: Author metadata using ArcCatalog
* `extract-thumbnail` :: Extract thumbnail preview from ArcCatalog metadata
* `extract-iso19139` :: Transform ISO 19139 metadata from ArcCatalog metadata
* `generate-geo-metadata` :: Convert ISO 19139 metadata into geoMetadata RDF XML file
* `generate-mods` :: Convert geoMetadata into MODS
* `assign-placenames` :: Insert linked data into MODS record from gazetteer
* `finish-metadata` :: Finalize the metadata preparation (validity check)
* `wrangle-data` :: Wrangle the data into the digital work (manual step)
* `package-data` :: Package the digital work
* `normalize-data` :: Reproject the data into common SRS projection and/or file format
* `extract-boundingbox` :: Extract bounding box from data for MODS record
* `finish-data` :: Finalize the data preparation (validity check)
* `generate-content-metadata` :: Generate contentMetadata manifest
* `load-geo-metadata` :: Accession geoMetadata xml into SDR
* `finish-gis-assembly-workflow` :: Finalize assembly workflow to prepare for assembly/delivery/discovery (validity check)
* `start-delivery-workflow` :: Kickstart the GIS delivery workflow at gisDeliveryWF


`gisDeliveryWF`
---------------

* `load-vector` :: Load vector data into PostGIS database
* `load-raster` :: Load raster into GeoTIFF data store
* `load-geoserver` :: Load layers into GeoServer
* `reset-geowebcache` :: Reset GeoWebCache for the layer

Data Wrangling
==============

Step 1: Preparing for stage
---------------------------

The file system structure will initially look like the following (see [Consul
page](https://consul.stanford.edu/x/C5xSC) for a description) where the temp
files for the shapefiles are all hard links to reduce space requirements: This
is *pre-stage*:

    zv925hd6723/
      temp/
        OGWELLS.dbf
        OGWELLS.prj
        OGWELLS.shp
        OGWELLS.shp.xml
        OGWELLS.shx


Step 2: Assembly
----------------

Then at the end of GIS assembly processing -- see above prior to accessioning -- it will
look like this in the workspace:

    zv925hd6723/
      metadata/
        contentMetadata.xml
        descMetadata.xml
        geoMetadata.xml
      content/
        data.zip
        data_ESRI_4326.zip
        preview.jpg
        some-other-file.ext (optionally)

# Reset Process (for QA/Stage)

## Requirements

None 🙂

* gis-robot-suite's only data store is the shared robots Redis.  Nothing needs to be done with this, since all robots will be quieted and the queues cleared as part of the larger reset process.
* Nothing special needs to be kept in terms of APOs, other than what the integration tests use (saving and reseeding that is already tracked elsewhere in the overall SDR reset process).  Same for agreements and collections.
* Earthworks: we expect/hope that the unpublish step of the overall SDR reset plan will take care of removing old Earthworks data, but we are not sure whether Earthworks responds to unpublish, so that is yet to be tested on our first QA/stage SDR reset attempt (planned for Sept 2023).
* We have checked with the main user of gis-robot-suite, and have confirmed that there is no test data that needs to be kept in stage or QA across resets.
* While gis-robot-suite connects to a geoserver database, that is maintained as part of the Access portfolio, and resetting it is outside the scope of an Infrastructure portfolio SDR reset.

## Steps

1. Delete all content under the directories pointed to by the following shared_configs settings for the given env (note: double-check the actual settings values, the examples are valid for stage and QA as of Aug 2023):
  - `Settings.geohydra.stage` (e.g. `'/var/geomdtk/current/stage'`)
  - `Settings.geohydra.workspace` (e.g. `'/var/geomdtk/current/workspace'`)
  - `Settings.geohydra.tmpdir` (e.g. `'/var/geomdtk/current/tmp'`)
  - `Settings.geohydra.geotiff.dir` (e.g. `'/var/geoserver/local/raster/geotiff'`)
  - `Settings.geohydra.opengeometadata.dir` (e.g. `'/var/geomdtk/current/export/opengeometadata/edu.stanford.purl'`)

Done.
