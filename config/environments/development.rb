Dor::Config.configure do

  workflow.url 'https://lyberservices-dev.stanford.edu/workflow/'

  robots do 
    workspace '/tmp'
  end

  was_crawl do
    
    source_path   '/dor/preassembly/' #the root for the storage for the input directory
    staging_path  '/dor/assembly/'  #the root for the storage for DRUID tree that will be the input to AssemblyWF
    extracted_metadata_xml_location   'tmp'
    metadata_extractor_jar  'jar/WASMetadataExtractor.jar'

  end
  suri do
    mint_ids true
    id_namespace 'druid'
    url 'https://lyberservices-dev.stanford.edu'
    user 'labware'
    pass 'lyberteam'
  end
  dor do
    service_root 'https://USERNAME:PASSWORD@lyberservices-dev.stanford.edu/dor'
  end
   
end
