[![CircleCI](https://circleci.com/gh/sul-dlss/gis-robot-suite.svg?style=svg)](https://circleci.com/gh/sul-dlss/gis-robot-suite)
[![Code Climate](https://codeclimate.com/github/sul-dlss/gis-robot-suite/badges/gpa.svg)](https://codeclimate.com/github/sul-dlss/gis-robot-suite)
[![Code Climate Test Coverage](https://codeclimate.com/github/sul-dlss/gis-robot-suite/badges/coverage.svg)](https://codeclimate.com/github/sul-dlss/)
[![GitHub version](https://badge.fury.io/gh/sul-dlss%2Fgis-robot-suite.svg)](https://badge.fury.io/gh/sul-dlss%2Fgis-robot-suite)

GIS-Robot-Suite
---------------

Robot code for accessioning and delivery of GIS resources.

# Dependencies
These robots require several dependencies needed to perform the GIS workflow steps. These are often shelled out to using `system` calls.

 - [GDAL](https://gdal.org/) Needed for geospatial tasks. For local development, this can be installed with brew.
 - `xsltproc` and `xmllint` for transforming XML files
 - rsync also used as part of the robot process and is needed

# Documentation

GIS data has its own set of names, standards and conventions that can be difficult for newcomers. To better understand some of these please see the [Geo4LibCamp Glossary](https://geo4libcamp.org/glossary/) as well as the following article which describes the initial goals for supporting GIS in SDR:

Kim Durante &amp; Darren Hardy (2015) Discovery, Management, and Preservation of Geospatial Data Using Hydra, Journal of Map &amp; Geography Libraries, 11:2, 123-154, DOI: [10.1080/15420353.2015.1041630](https://doi.org/10.1080/15420353.2015.1041630).

*gis-robot-suite* services two workflows: *gisAssemblyWF* and *gisDeliveryWF*.

`gisAssemblyWF`
---------------

* `extract-iso19139-metadata` :: Transform ISO 19139 metadata from ArcCatalog metadata
* `extract-iso19110-metadata` :: Transform ISO 19110metadata from ArcCatalog metadata
* `extract-fgdc-metadata` :: Transform FGDC metadata from ArcCatalog metadata
* `generate-geo-metadata` :: Convert ISO 19139 metadata into geoMetadata RDF XML file
* `generate-tag` :: Apply Geo tag to object
* `generate-mods` :: Convert geoMetadata into MODS
* `assign-placenames` :: Insert linked data into MODS record from gazetteer
* `package-data` :: Package the digital work
* `normalize-data` :: Reproject the data into common SRS projection and/or file format, move files from temp to content directory, and generate data_EPSG_4326.zip.
* `extract-boundingbox` :: Extract bounding box from data for MODS record
* `generate-structural` :: Generate structural metadata and update the Cocina data store accordingly
* `finish-gis-assembly-workflow` :: Finalize assembly workflow to prepare for assembly/delivery/discovery (validity check)
* `start-delivery-workflow` :: Kickstart the GIS delivery workflow at gisDeliveryWF


`gisDeliveryWF`
---------------

* `load-vector` :: Load vector data into PostGIS database
* `load-raster` :: Load raster into GeoTIFF data store
* `load-geoserver` :: Load layers into GeoServer
* `reset-geowebcache` :: Reset GeoWebCache for the layer
* `finish-gis-delivery-workflow` :: Connect to public and restricted GeoServers to verify layer
* `reload-geoserver` :: Automatically reload the GeoServer
* `start-accession-workflow` :: Start accessionWF

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
        preview.jpg
      content/
        index_map.json

Note that `content/index_map.json` is optional.


Step 2: Assembly
----------------

Then at the end of GIS assembly processing -- see above prior to accessioning -- it will
look like this in the workspace:

    zv925hd6723/
      content/
        data.zip
        data_ESRI_4326.zip
        preview.jpg
        index_map.json
        layer-iso19110.xml
        layer-iso19139.xml
        layer-fgdc.xml
        layer.shp.xml

Note that `content/index_map.json` is optional.

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
