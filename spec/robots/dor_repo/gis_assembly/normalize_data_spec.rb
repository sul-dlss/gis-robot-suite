# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::NormalizeData do
  let(:robot) { described_class.new }

  describe '.projection_from_cocina' do
    let(:projection) { robot.send(:projection_from_cocina) }
    let(:cocina_object) { build(:dro, id: 'druid:nj441df9572').new(description:) }
    let(:description) do
      {
        title: [{ value: 'McDonald Islands, 2015' }],
        purl: 'https://purl.stanford.edu/nj441df9572',
        form: [
          {
            value: 'Scale not given.',
            type: 'map scale'
          },
          {
            value: 'EPSG::4326',
            type: 'map projection',
            uri: 'http://opengis.net/def/crs/EPSG/0/4326',
            source: {
              code: 'EPSG'
            },
            displayLabel: 'WGS84'
          },
          {
            value: 'Custom projection',
            type: 'map projection'
          }
        ]
      }
    end

    before do
      allow(robot).to receive(:cocina_object).and_return(cocina_object)
    end

    it 'extracts the projection' do
      expect(projection).to eq('Custom projection')
    end
  end
end
