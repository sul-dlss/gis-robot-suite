# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::StartAccessionWorkflow do
  let(:robot) { described_class.new }
  let(:druid) { 'fx392st8577' }
  let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, close: nil) }

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(robot.logger).to receive(:debug)
  end

  describe '#perform_work' do
    it 'logs a debug message' do
      test_perform(robot, druid)
      expect(robot.logger).to have_received(:debug).once.with("start-accession-workflow working on #{druid}").once
    end

    it 'uses dor-services-client to close the object version' do
      test_perform(robot, druid)
      expect(version_client).to have_received(:close).once
    end
  end
end
