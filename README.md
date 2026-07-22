[![CircleCI](https://circleci.com/gh/sul-dlss/gis-robot-suite.svg?style=svg)](https://circleci.com/gh/sul-dlss/gis-robot-suite)
[![codecov](https://codecov.io/github/sul-dlss/gis-robot-suite/graph/badge.svg?token=ZilsIAOJk7)](https://codecov.io/github/sul-dlss/gis-robot-suite)

## GIS-Robot-Suite

Robot code for accessioning and delivery of GIS resources.

# Developing

## System dependencies

These robots require several dependencies needed to perform the GIS workflow steps. These are often shelled out to using `system` calls.

- [GDAL](https://gdal.org/) Needed for geospatial tasks. For local development, this can be installed with `brew`.
- `xsltproc` and `xmllint` for transforming XML files

## Running system commands

There are many ways to execute commands on the host OS in Ruby. For calling the aforementioned tools (GDAL commands, `xsltproc`, etc), it's suggested to first reach for `GisRobotSuite.run_system_command`, since that is consistent with the rest of the codebase, and includes some helpful logging and error handling.

## Tests

You can run the tests with `bundle exec rspec`. The tests are organized by workflow, and each robot has its own test file.

Because the robots move content around on the filesystem, the tests make use of temporary directories as well as some setup/teardown to ensure files aren't left behind.

## Troubleshooting

> [!TIP]
> To learn how to accession your own GIS items using Preassembly, see the Data Curation section of the [documentation on Consul](https://consul.stanford.edu/spaces/SULAIRGIS/pages/131950215/SUL+GIS+Services+Home).

You can get a high-level overview of the current processing status of items in SDR using [Argo's workflow grid view](https://argo.stanford.edu/report/workflow_grid?f%5Bcontent_type_ssimdv%5D%5B%5D=geo). If you track down a problem and deploy a fix, you can retry the items stuck in a particular stage by clicking the red "reset" button in the error column.

If you need to export a list of objects to troubleshoot, you can use [Argo's report view](https://argo.stanford.edu/report?f%5Bcontent_type_ssimdv%5D%5B%5D=geo), which offers the option to customize which columns are downloaded in the output CSV. Many scripts, including the ones in `bin/`, can take a CSV of druids as input.

For individual items, you can visit their page in Argo and click the workflow name in the "History" section to see the output from each workflow step. This provides an option to retry or skip each stage in the workflow.

To execute a single workflow step, you can invoke the `./bin/run_robot` script from this repository while logged into the remote machine (the object must be opened for versioning). There is also [a script available on the `dor-services-app` VMs](https://github.com/sul-dlss/dor-services-app#reset-accessioning-for-one-or-more-druids) that can be used to reset the workflow state for one or many objects.

# Design

> [!TIP]
> GIS data has its own set of names, standards and conventions that can be difficult for newcomers. To better understand some of these please see the [Geo4LibCamp Glossary](https://geo4libcamp.org/glossary/) and the [Consul documentation on GIS data formats](https://consul.stanford.edu/spaces/SULAIRGIS/pages/158238237/SUL+Geospatial+Data+Curation+Workflow).

This repository services two workflows: _gisAssemblyWF_ and _gisDerivativeWF_. Each workflow consists of a number of separate "robots", each of which has one responsibility. The robots in each workflow are invoked in order. The robot code lives in `lib/robots/dor_repo` and is organized by workflow.

Most complex operations, like generating derivatives, are broken out into their own ruby classes in `lib/gis_robot_suite`, which are imported by the robots that use them. The XSLT files used for transforming XML metadata are in `config/ArcGIS`.

> [!IMPORTANT]
> This repository provides the robot code for the workflows, but the workflows themselves are defined externally. If a new workflow is created or the robots are re-ordered, the [workflow definitions in dor-services-app](https://github.com/sul-dlss/dor-services-app/tree/main/config/workflows) must be updated (and changes may also need to be made in Argo).

## Data processing

Data and metadata are moved around on the filesystem during processing, including to and from shared volumes that are also accessed by other systems. Incoming files from preassembly are uploaded to a volume mounted at `/gis_workflow_data`; after processing is completed the files will be located on the volume mounted at `/dor`, which is shared with other SDR systems.

## `gisAssemblyWF`

This workflow runs after data has been accessioned using preassembly. Its responsibilities are:

- Generate the Cocina descriptive and structural metadata for the object
- Generate additional XML metadata formats like ISO19139 and FGDC from the source metadata
- Enrich metadata using some properties from the data, like bounding box and projection
- Invoke `gisDerivativeWF` to generate derivatives for the data

At the end of this workflow, the files will be copied to the `/dor` volume, where `gisDerivativeWF` looks for them.

## `gisDerivativeWF`

This workflow is automatically invoked by `gisAssemblyWF`, and can also be invoked manually in Argo. Its responsibilities are:

- Generate cloud-optimized versions of the data that can be previewed in a web browser
- Generate a thumbnail image for the data
- Invoke `accessionWF` to send the object to preservation and delivery systems

All of the files created by this workflow have the `derivative` file role in SDR, and have the `sdrGeneratedText` attribute set to `true`. If an object contains existing derivatives with `sdrGeneratedText` set to `false`, this workflow will not attempt to overwrite them.

At the end of this workflow, the files on the `/dor` volume will be handed off to the `accessionWF` workflow, which is serviced by [common-accessioning](https://github.com/sul-dlss/common-accessioning) on a different set of VMs.
