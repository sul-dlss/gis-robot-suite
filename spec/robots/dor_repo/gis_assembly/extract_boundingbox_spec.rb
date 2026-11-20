# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::ExtractBoundingbox do
  let(:robot) { described_class.new }
  let(:druid) { 'druid:cc044gt0726' }
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: build(:dro, id: druid), update: nil) }

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
  end

  it 'skips the step without updating the object, now that earlier steps record the bounding box' do
    result = test_perform(robot, druid)

    expect(result.status).to eq 'skipped'
    expect(result.note).to include 'extract-iso19139-metadata'
    expect(object_client).not_to have_received(:update)
  end
end
