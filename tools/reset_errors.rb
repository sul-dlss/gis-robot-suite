#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../config/boot')

Dir.glob("druid_errors*.txt").each do |fn|
  File.open(fn, 'rb').readlines.each do |druid|
    druid.strip!
    puts "Processing #{druid}"
    r, w, s = %w{dor gisAssemblyWF generate-mods}
    Dor::WorkflowService.update_workflow_status(r, druid, w, s, 'waiting')
    r, w, s = %w{dor gisAssemblyWF assign-placenames}
    Dor::WorkflowService.update_workflow_status(r, druid, w, s, 'waiting')
    r, w, s = %w{dor gisAssemblyWF finish-metadata}
    Dor::WorkflowService.update_workflow_status(r, druid, w, s, 'waiting')
  end
end
