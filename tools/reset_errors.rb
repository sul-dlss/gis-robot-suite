#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../config/boot')

Dir.glob('druid_errors*.txt').each do |fn|
  File.open(fn, 'rb').readlines.each do |druid|
    druid.strip!
    puts "Processing #{druid}"
    r = 'dor'
    w = 'gisAssemblyWF'
    s = 'generate-mods'
    Dor::WorkflowService.update_workflow_status(r, druid, w, s, 'waiting')
    s = 'assign-placenames'
    Dor::WorkflowService.update_workflow_status(r, druid, w, s, 'waiting')
    s = 'finish-metadata'
    Dor::WorkflowService.update_workflow_status(r, druid, w, s, 'waiting')
  end
end
