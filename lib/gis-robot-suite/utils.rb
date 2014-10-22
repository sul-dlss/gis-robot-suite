module GisRobotSuite
  def self.locate_druid_path druid, opts = {}
    rootdir = '.'
    pid = druid.gsub(/^druid:/, '')

    if opts[:type] == :stage
      rootdir = Dor::Config.geohydra.stage
      rootdir = File.join(rootdir, pid)
    elsif opts[:type] == :workspace
      rootdir = DruidTools::Druid.new(druid, Dor::Config.geohydra.workspace).path
    else
      raise NotImplementedError, 'Only :stage, :workspace are supported'
    end
    
    raise RuntimeError, "Missing #{rootdir}" if opts[:validate] && !File.directory?(rootdir)
    rootdir
  end
  
  def self.locate_esri_metadata dir, opts = {}
    fn = Dir.glob("#{dir}/*.shp.xml").first # Shapefile
    if fn.nil? || File.size(fn) == 0
      fn = Dir.glob("#{dir}/*.tif.xml").first # GeoTIFF
      if fn.nil? || File.size(fn) == 0
        fn = Dir.glob("#{dir}/*/metadata.xml").first # ArcGRID
        if fn.nil? || File.size(fn) == 0
          raise RuntimeError, "Missing ESRI metadata files in #{dir}"
        end
      end
    end
    fn
  end
  
  def self.determine_file_format_from_mods modsfn
    doc = Nokogiri::XML(File.read(modsfn))
    format = doc.xpath('/mods:mods/mods:extension[@displayLabel="geo"]/*/*/dc:format', 
                       'mods' => 'http://www.loc.gov/mods/v3', 
                       'dc' => 'http://purl.org/dc/elements/1.1/').first
    unless format.nil?
      format = format.text
    end
    format
  end


  # <extension displayLabel="geo">
  #   <rdf:RDF xmlns:gml="http://www.opengis.net/gml/3.2/" xmlns:dc="http://purl.org/dc/elements/1.1/">
  #     <rdf:Description rdf:about="http://purl.stanford.edu/dd452vk1873">
  #       <dc:format>image/tiff; format=ArcGRID</dc:format>
  #       <dc:type>Dataset#Raster</dc:type>
  #       <gml:boundedBy>
  #         <gml:Envelope gml:srsName="EPSG:4326">
  #           <gml:lowerCorner>-180 -90</gml:lowerCorner>
  #           <gml:upperCorner>180 84</gml:upperCorner>
  #         </gml:Envelope>
  #       </gml:boundedBy>
  #       <dc:coverage rdf:resource="http://sws.geonames.org/6295630/about.rdf" dc:language="eng" dc:title="Earth"/>
  #     </rdf:Description>
  #   </rdf:RDF>

  def self.determine_projection_from_mods modsfn
    doc = Nokogiri::XML(File.read(modsfn))
    proj = doc.xpath('/mods:mods/mods:extension[@displayLabel="geo"]/*/*/gml:boundedBy/gml:Envelope', 
                       'mods' => 'http://www.loc.gov/mods/v3', 
                       'gml' => 'http://www.opengis.net/gml/3.2/').first
    unless proj.nil?
      proj = proj['gml:srsName']
    end
    proj.to_s.upcase
  end

end