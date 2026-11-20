# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GisRobotSuite::EsriReferenceSystem do
  describe '.crs' do
    subject(:crs) { described_class.crs(Nokogiri::XML("<metadata><refSysInfo>#{ref_systems}</refSysInfo></metadata>")) }

    def ref_system(code_space, sync: false, **ident_code)
      attributes = ident_code.map { |name, value| %(#{name}="#{value}") }
      attributes << 'Sync="TRUE"' if sync
      "<RefSystem><refSysID><identCode #{attributes.join(' ')}/><idCodeSpace>#{code_space}</idCodeSpace></refSysID></RefSystem>"
    end

    context 'with one reference system' do
      let(:ref_systems) { ref_system('ESRI', code: '54009', sync: true) }

      it 'names it as authority and code' do
        expect(crs).to eq 'ESRI:54009'
      end
    end

    context 'with an authored reference system and one ArcGIS synced from the data' do
      let(:ref_systems) { ref_system('EPSG', code: '26910') + ref_system('EPSG', code: '4326', sync: true) }

      it 'prefers the synced one' do
        expect(crs).to eq 'EPSG:4326'
      end
    end

    context 'with the code as the text of identCode' do
      let(:ref_systems) { '<RefSystem><refSysID><identCode>32652</identCode><idCodeSpace>EPSG</idCodeSpace></refSysID></RefSystem>' }

      it 'reads it from there' do
        expect(crs).to eq 'EPSG:32652'
      end
    end

    context 'with no code space' do
      let(:ref_systems) { '<RefSystem><refSysID><identCode code="54009"/></refSysID></RefSystem>' }

      it 'names none' do
        expect(crs).to be_nil
      end
    end

    context 'with no reference system' do
      let(:ref_systems) { '' }

      it 'names none' do
        expect(crs).to be_nil
      end
    end
  end
end
