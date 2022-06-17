# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisAssembly::GenerateContentMetadata do
  let(:robot) { described_class.new }
  let(:druid) { 'druid:bb222cc3333' }
  let(:type) { 'item' }

  let(:structural) { {} }
  let(:cocina_model) { build(:dro, id: druid).new(structural: structural) }

  let(:object_client) do
    instance_double(Dor::Services::Client::Object, find: cocina_model, update: true)
  end

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
  end

  describe '#perform_work' do
    before do
      allow(robot).to receive(:create_content_metadata).and_return([])
    end

    it 'creates structural' do
      test_perform(robot, druid)
      expect(object_client).to have_received(:update)
    end
  end
end
