# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

require_relative '../../bin/migration_unzip_files'

RSpec.describe Migrator do # rubocop:disable RSpec/SpecFilePathFormat
  describe '.process_csv' do
    let(:csv) do
      file = Tempfile.new(['druids', '.csv'])
      file.write("druid\n#{missing_druid}\n#{ok_druid}\n")
      file.close
      file
    end
    let(:missing_druid) { 'aa111bb2222' }
    let(:ok_druid) { 'cc333dd4444' }

    before do
      allow(described_class).to receive(:migrate).with(druid: missing_druid)
                                                 .and_raise(described_class::MissingDataZip, 'No data.zip found')
      allow(described_class).to receive(:migrate).with(druid: ok_druid)
    end

    after { csv.unlink }

    it 'skips a druid whose data.zip is missing and continues processing the rest' do
      # Silence the skip warning so it doesn't clutter RSpec output.
      allow(described_class).to receive(:warn)

      expect { described_class.process_csv(csv.path) }.not_to raise_error

      expect(described_class).to have_received(:migrate).with(druid: missing_druid)
      expect(described_class).to have_received(:migrate).with(druid: ok_druid)
    end

    it 'reports the skipped druid on stderr' do
      expect { described_class.process_csv(csv.path) }
        .to output(/Skipping #{missing_druid}: No data.zip found/).to_stderr
    end
  end
end
