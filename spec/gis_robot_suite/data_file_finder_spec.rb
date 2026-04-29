# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::DataFileFinder do
  subject(:files) { described_class.find(content_dir:) }

  let(:content_dir) { 'spec/fixtures/stage' }

  context 'when a pmtiles file is present' do
    let(:pmtiles_path) { File.join(content_dir, 'foo.pmtiles') }

    around do |example|
      File.write(pmtiles_path, 'foobar')
      example.run
      FileUtils.rm_f(pmtiles_path)
    end

    it { is_expected.to eq [pmtiles_path] }
  end
end
