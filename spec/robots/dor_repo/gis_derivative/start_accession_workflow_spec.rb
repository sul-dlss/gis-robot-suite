# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDerivative::StartAccessionWorkflow do
  let(:robot) { described_class.new }
  let(:druid) { 'fx392st8577' }
  let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, close: nil) }
  let(:process_response) { instance_double(Dor::Services::Response::Process, lane_id: 'high', context:) }
  let(:context) { {} }
  let(:workflow_response) { instance_double(Dor::Services::Response::Workflow, process_for_recent_version: process_response) }
  let(:object_workflow) { instance_double(Dor::Services::Client::ObjectWorkflow, find: workflow_response) }

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(object_client).to receive(:workflow).with('gisDerivativeWF').and_return(object_workflow)
    allow(robot.logger).to receive(:debug)
  end

  describe '#perform_work' do
    it 'logs a debug message' do
      test_perform(robot, druid)
      expect(robot.logger).to have_received(:debug).once.with("start-accession-workflow working on #{druid}").once
    end

    it 'closes the object version in the workflow lane' do
      test_perform(robot, druid)
      expect(version_client).to have_received(:close).once.with(lane_id: 'high', user_versions: nil)
    end

    context 'when the workflow context has a user version mode' do
      let(:context) { { 'userVersions' => 'new' } }

      it 'closes the object version with the user version mode' do
        test_perform(robot, druid)
        expect(version_client).to have_received(:close).once.with(lane_id: 'high', user_versions: 'new')
      end
    end
  end
end
