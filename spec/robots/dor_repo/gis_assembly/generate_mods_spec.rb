# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::GenerateMods do
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }

  before do
    allow(WorkflowClientFactory).to receive(:build).and_return(workflow_client)
  end

  it 'converts DD to DDMMSS' do
    expect(subject.dd2ddmmss_abs('-109.758319')).to eq('109°45ʹ30ʺ')
    expect(subject.dd2ddmmss_abs('48.999336')).to eq('48°59ʹ58ʺ')
  end

  it 'converts MARC to DDMMSS' do
    expect(subject.to_coordinates_ddmmss('-180 -- 180/90 -- -90')).to eq('W 180°--E 180°/N 90°--S 90°')
    expect(subject.to_coordinates_ddmmss('-109.758319 -- -88.990844/48.999336 -- 29.423028')).to eq('W 109°45ʹ30ʺ--W 88°59ʹ27ʺ/N 48°59ʹ58ʺ--N 29°25ʹ23ʺ')
  end

  it 'handles bad arguments' do
    expect { subject.to_coordinates_ddmmss('-185 -- 185/95 -- -95') }.to raise_error(ArgumentError)
  end

  describe '#to_mods' do
    let(:geo_metadata) { Nokogiri::XML(read_fixture('geoMetadata.xml')) }

    it 'runs without error' do
      expect do
        subject.to_mods(geo_metadata, { purl: 'https://purl.stanford.edu/ym947vs2726', newfoo: '123' })
      end.not_to raise_error
    end
  end
end
