module GisRobotSuite
  def self.druid_path druid, opts = {}
    pid = druid.gsub(/^druid:/, '')

    if opts[:type] == :stage
      rootdir = Dor::Config.geohydra.stage
    end
    
    return File.join(rootdir, pid)
    
  end
  
  def self.locate_esri_metadata dir, opts = {}
    fn = Dir.glob("#{dir}/*.shp.xml").first # Shapefile
    if fn.nil? || File.size(fn) == 0
      fn = Dir.glob("#{dir}/*.tif.xml").first # GeoTIFF
      if fn.nil? || File.size(fn) == 0
        fn = Dir.glob("#{dir}/*/metadata.xml").first # ArcGRID
        if fn.nil? || File.size(fn) == 0
          fn = nil
        end
      end
    end
    fn
  end
end