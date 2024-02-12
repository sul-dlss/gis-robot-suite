# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Robots::DorRepo::GisDelivery::ReloadGeoserver do
  subject(:reload_geoserver) { test_perform(robot, druid) }

  let(:robot) { described_class.new }

  let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object) }
  let(:druid) { 'bb338jh0716' }
  let(:cocina_object_access) { 'world' }
  let(:cocina_object) do
    dro = build(:dro, id: "druid:#{druid}")
    dro.new(
      access: { view: cocina_object_access, download: cocina_object_access }
    )
  end

  let(:conn_public_primary_params) do
    {
      'url' => Settings.geoserver.public.primary.url,
      'user' => Settings.geoserver.public.primary.user,
      'password' => Settings.geoserver.public.primary.password
    }
  end
  let(:conn_public_replica_params) do
    {
      'url' => Settings.geoserver.public.replica.url,
      'user' => Settings.geoserver.public.replica.user,
      'password' => Settings.geoserver.public.replica.password
    }
  end
  let(:conn_restricted_primary_params) do
    {
      'url' => Settings.geoserver.restricted.primary.url,
      'user' => Settings.geoserver.restricted.primary.user,
      'password' => Settings.geoserver.restricted.primary.password
    }
  end
  let(:conn_restricted_replica_params) do
    {
      'url' => Settings.geoserver.restricted.replica.url,
      'user' => Settings.geoserver.restricted.replica.user,
      'password' => Settings.geoserver.restricted.replica.password
    }
  end

  let(:geoserver_conn_public_primary) { instance_double(Geoserver::Publish::Connection) }
  let(:geoserver_conn_public_replica) { instance_double(Geoserver::Publish::Connection) }
  let(:geoserver_conn_restricted_primary) { instance_double(Geoserver::Publish::Connection) }
  let(:geoserver_conn_restricted_replica) { instance_double(Geoserver::Publish::Connection) }

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
  end

  describe '#perform_work' do
    context 'with an object that is considered public' do
      before do
        allow(Geoserver::Publish::Connection).to receive(:new).with(conn_public_primary_params).and_return(geoserver_conn_public_primary)
        allow(Geoserver::Publish::Connection).to receive(:new).with(conn_public_replica_params).and_return(geoserver_conn_public_replica)
        allow(geoserver_conn_public_primary).to receive(:post)
        allow(geoserver_conn_public_replica).to receive(:post)
        allow(geoserver_conn_restricted_primary).to receive(:post)
        allow(geoserver_conn_restricted_replica).to receive(:post)
      end

      it 'posts to the public geoserver instances' do
        reload_geoserver
        expect(Geoserver::Publish::Connection).to have_received(:new).with(conn_public_primary_params)
        expect(geoserver_conn_public_primary).to have_received(:post).with(path: 'reload', payload: nil)
        expect(Geoserver::Publish::Connection).to have_received(:new).with(conn_public_replica_params)
        expect(geoserver_conn_public_replica).to have_received(:post).with(path: 'reload', payload: nil)
      end

      it 'does not post to the restricted geoserver instances' do
        reload_geoserver
        expect(Geoserver::Publish::Connection).not_to have_received(:new).with(conn_restricted_primary_params)
        expect(geoserver_conn_restricted_primary).not_to have_received(:post)
        expect(Geoserver::Publish::Connection).not_to have_received(:new).with(conn_restricted_replica_params)
        expect(geoserver_conn_restricted_replica).not_to have_received(:post)
      end
    end

    context 'with an object that is considered restricted' do
      let(:cocina_object_access) { 'stanford' }

      before do
        allow(Geoserver::Publish::Connection).to receive(:new).with(conn_restricted_primary_params).and_return(geoserver_conn_restricted_primary)
        allow(Geoserver::Publish::Connection).to receive(:new).with(conn_restricted_replica_params).and_return(geoserver_conn_restricted_replica)
        allow(geoserver_conn_public_primary).to receive(:post)
        allow(geoserver_conn_public_replica).to receive(:post)
        allow(geoserver_conn_restricted_primary).to receive(:post)
        allow(geoserver_conn_restricted_replica).to receive(:post)
      end

      it 'does not post to the public geoserver instances' do
        reload_geoserver
        expect(Geoserver::Publish::Connection).not_to have_received(:new).with(conn_public_primary_params)
        expect(geoserver_conn_public_primary).not_to have_received(:post)
        expect(Geoserver::Publish::Connection).not_to have_received(:new).with(conn_public_replica_params)
        expect(geoserver_conn_public_replica).not_to have_received(:post)
      end

      it 'posts to the restricted geoserver instances' do
        reload_geoserver
        expect(Geoserver::Publish::Connection).to have_received(:new).with(conn_restricted_primary_params)
        expect(geoserver_conn_restricted_primary).to have_received(:post).with(path: 'reload', payload: nil)
        expect(Geoserver::Publish::Connection).to have_received(:new).with(conn_restricted_replica_params)
        expect(geoserver_conn_restricted_replica).to have_received(:post).with(path: 'reload', payload: nil)
      end
    end

    context 'when the geoserver connection times out' do
      before do
        allow(Geoserver::Publish::Connection).to receive(:new).with(conn_public_primary_params).and_return(geoserver_conn_public_primary)
        allow(Geoserver::Publish::Connection).to receive(:new).with(conn_public_replica_params).and_return(geoserver_conn_public_replica)
        allow(geoserver_conn_public_primary).to receive(:post)
        allow(geoserver_conn_public_replica).to receive(:post)
      end

      context 'when the retry limit is not exceeded' do # rubocop:disable RSpec/NestedGroups
        before do
          call_count = 0
          allow(geoserver_conn_public_replica).to receive(:post) do
            call_count += 1
            raise(Faraday::TimeoutError) if call_count < Settings.connection_error_max_retries
          end
        end

        it 'posts to the public geoserver instances' do
          expect { reload_geoserver }.not_to raise_error
          expect(Geoserver::Publish::Connection).to have_received(:new).with(conn_public_primary_params)
          expect(geoserver_conn_public_primary).to have_received(:post).with(path: 'reload', payload: nil).once
          expect(Geoserver::Publish::Connection).to have_received(:new).with(conn_public_replica_params)
          expect(geoserver_conn_public_replica).to have_received(:post).with(path: 'reload', payload: nil).exactly(3).times
        end
      end

      context 'when the retry limit is reached' do # rubocop:disable RSpec/NestedGroups
        before do
          allow(geoserver_conn_public_replica).to receive(:post).and_raise(Faraday::TimeoutError)
        end

        it 'lets the connection failure bubble up' do
          expect { reload_geoserver }.to raise_error(Faraday::TimeoutError)
          expect(Geoserver::Publish::Connection).to have_received(:new).with(conn_public_primary_params)
          expect(geoserver_conn_public_primary).to have_received(:post).with(path: 'reload', payload: nil).once
          expect(Geoserver::Publish::Connection).to have_received(:new).with(conn_public_replica_params)
          expect(geoserver_conn_public_replica).to have_received(:post).with(path: 'reload', payload: nil).exactly(3).times
        end
      end
    end
  end
end
