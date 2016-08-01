#!/bin/bash -x

for i in \
	edu.columbia \
	edu.michstate \
        edu.nyu \
        edu.princeton.arks \
	edu.purdue \
	edu.uiowa \
	edu.umaryland \
	edu.umich \
        edu.umn \
	edu.uwisc \
        edu.virginia \
  ; do
        test -d $i || git clone --depth=1 git@github.com:OpenGeoMetadata/$i.git
done
        
test -d edu.stanford.purl || git clone git@github.com:OpenGeoMetadata/edu.stanford.purl.git
(cd edu.stanford.purl; git checkout july-2016)


