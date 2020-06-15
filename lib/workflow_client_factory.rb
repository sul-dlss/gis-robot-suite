# frozen_string_literal: true

class WorkflowClientFactory
  def self.build
    logger = Logger.new(Settings.workflow.logfile, Settings.workflow.shift_age)
    Dor::Workflow::Client.new(url: Settings.workflow.url, logger: logger, timeout: Settings.workflow.timeout)
  end
end
