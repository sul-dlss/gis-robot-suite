[![Build Status](https://travis-ci.org/sul-dlss/gis-robot-suite.svg?branch=master)](https://travis-ci.org/sul-dlss/gis-robot-suite)

GIS-Robot-Suite
---------------

Robot code for accessioning, delivery, and discovery of GIS resources.


# Documentation

Check the [Wiki](https://github.com/sul-dlss/robot-master/wiki) in the robot-master repo.

To run, use the `lyber-core` infrastructure, which uses `bundle exec controller boot` 
to start all robots defined in `config/environments/robots_ENV.yml`.

`gisAssemblyWF`
---------------

* `register-druid` :: Ensure proper registration of druid, source ID, and label
* `author-metadata` :: Author metadata using ArcCatalog
* `approve-metadata` :: Approve metadata quality and release for workflow (manual step)
* `extract-thumbnail` :: Extract thumbnail preview from ArcCatalog metadata
* `extract-iso19139` :: Transform ISO 19139 metadata from ArcCatalog metadata
* `generate-geo-metadata` :: Convert ISO 19139 metadata into geoMetadata datastream
* `generate-mods` :: Convert geoMetadata into MODS
* `assign-placenames` :: Insert linked data into MODS record from gazetteer
* `finish-metadata` :: Finalize the metadata preparation (validity check)
* `wrangle-data` :: Wrangle the data into the digital work (manual step)
* `approve-data` :: Approve data quality for digital work and release for workflow (manual step)
* `package-data` :: Package the digital work
* `normalize-data` :: Reproject the data into common SRS projection and/or file format
* `extract-boundingbox` :: Extract bounding box from data for MODS record
* `finish-data` :: Finalize the data preparation (validity check)
* `generate-content-metadata` :: Generate contentMetadata manifest
* `load-geo-metadata` :: Accession geoMetadata datastream into DOR repository
* `finish-gis-assembly-workflow` :: Finalize assembly workflow to prepare for assembly/delivery/discovery (validity check)
* `start-assembly-workflow` :: Kickstart the core assembly workflow at assemblyWF (manual step)
* `start-delivery-workflow` :: Kickstart the GIS delivery workflow at gisDeliveryWF (manual step)

`gisDeliveryWF`
---------------

* `load-vector` :: Load vector data into PostGIS database
* `load-raster` :: Load raster into GeoTIFF data store
* `load-geoserver` :: Load layers into GeoServer
* `load-geowebcache` :: Load layers into GeoWebCache (skipped)
* `seed-geowebcache` :: Generate tiles for GeoWebCache layers (skipped)
* `finish-gis-delivery-workflow` :: Finalize delivery workflow for the object (validity check)
* `start-gis-discovery-workflow` :: Kickstart GIS discovery workflow with gisDiscoveryWF (manual step)

`gisDiscoveryWF`
----------------

* `generate-geoblacklight` :: Generate Solr document for GeoBlacklight schema
* `load-geoblacklight` :: Load Solr document into GeoBlacklight Solr index
* `export-opengeometadata` :: Export metadata files for import into OpenGeoMetadata repository
* `finish-gis-discovery-workflow` :: Finalize GIS discovery workflow for the object (validity check
)

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

Then at the end of assembly processing -- see above prior to accessioning -- it will
look like in your workspace:

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
