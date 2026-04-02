# frozen_string_literal: true

require 'spec_helper'

describe Turndown::Provider::File do
  subject(:provider) { described_class.new }

  describe '#active_state' do
    context 'when no maintenance file exists' do
      before do
        allow(Turndown::MaintenanceFile).to receive(:find).and_return(nil)
      end

      it 'returns nil' do
        expect(provider.active_state).to be_nil
      end
    end

    context 'when a maintenance file is found' do
      let(:maint_file) do
        instance_double(
          Turndown::MaintenanceFile,
          reason:        'Scheduled maintenance',
          allowed_paths: ['/health'],
          allowed_ips:   ['10.0.0.1'],
          response_code: 503,
          retry_after:   3600
        )
      end

      before do
        allow(Turndown::MaintenanceFile).to receive(:find).and_return(maint_file)
      end

      it 'returns a MaintenanceState' do
        expect(provider.active_state).to be_a(Turndown::MaintenanceState)
      end

      it 'sets reason from the maintenance file' do
        expect(provider.active_state.reason).to eq('Scheduled maintenance')
      end

      it 'sets allowed_paths from the maintenance file' do
        expect(provider.active_state.allowed_paths).to eq(['/health'])
      end

      it 'sets allowed_ips from the maintenance file' do
        expect(provider.active_state.allowed_ips).to eq(['10.0.0.1'])
      end

      it 'sets response_code from the maintenance file' do
        expect(provider.active_state.response_code).to eq(503)
      end

      it 'sets retry_after from the maintenance file' do
        expect(provider.active_state.retry_after).to eq(3600)
      end
    end
  end
end
