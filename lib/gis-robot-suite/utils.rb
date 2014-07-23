module GisRobotSuite
  def self.druid_path druid, opts = {}
    pid = druid.gsub(/^druid:/, '')

    if opts[:type] == :stage
      rootdir = Dor::Config.geohydra.stage
    end
    
    return File.join(rootdir, pid)
    
  end