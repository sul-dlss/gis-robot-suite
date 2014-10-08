module GisRobotSuite
  def self.locate_druid_path druid, opts = {}
    rootdir = '.'
    pid = druid.gsub(/^druid:/, '')

    if opts[:type] == :stage
      rootdir = Dor::Config.geohydra.stage
      rootdir = File.join(rootdir, pid)
    else
      raise NotImplementedError, 'Only :stage is supported'
    end
    
    raise RuntimeError, "Missing #{rootdir}" unless File.directory?(rootdir)    
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
end