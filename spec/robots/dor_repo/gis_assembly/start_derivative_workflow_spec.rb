# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::StartDerivativeWorkflow do
  subject(:perform) { test_perform(robot, druid) }

  let(:robot) { described_class.new }
  let(:druid) { 'druid:zz000zz0001' }
  let(:current_version) { 2 }
  let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, current: current_version) }
  let(:workflow_client) { instance_double(Dor::Services::Client::ObjectWorkflow, create: true) }
  let(:object_client) do
    instance_double(Dor::Services::Client::Object, version: version_client, workflow: workflow_client)
  end

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
  end

  it 'creates the GIS derivative workflow for the current object version' do
    perform

    expect(object_client).to have_received(:workflow).with('gisDerivativeWF')
    expect(workflow_client).to have_received(:create).with(version: current_version)
  end
end
