# frozen_string_literal: true

require 'spec_helper'

describe Turndown::Provider::Env do
  subject(:provider) { described_class.new }

  # Capture ENV keys set during each example so they can be removed afterward.
  around(:each) do |example|
    keys_before = ENV.keys.dup
    example.run
    (ENV.keys - keys_before).each { |k| ENV.delete(k) }
  end

  def set_env(key, value)
    ENV[key] = value
  end

  describe '#active_state' do
    context 'when TURNDOWN_ENABLED is not set' do
      it 'returns nil' do
        expect(provider.active_state).to be_nil
      end
    end

    context 'with falsy TURNDOWN_ENABLED values' do
      %w[0 false no off].each do |falsy|
        it "returns nil for '#{falsy}'" do
          set_env('TURNDOWN_ENABLED', falsy)
          expect(provider.active_state).to be_nil
        end
      end
    end

    context 'with truthy TURNDOWN_ENABLED values' do
      %w[1 true yes on].each do |truthy|
        it "returns a MaintenanceState for '#{truthy}'" do
          set_env('TURNDOWN_ENABLED', truthy)
          expect(provider.active_state).to be_a(Turndown::MaintenanceState)
        end
      end

      it 'is case-insensitive (TRUE)' do
        set_env('TURNDOWN_ENABLED', 'TRUE')
        expect(provider.active_state).to be_a(Turndown::MaintenanceState)
      end

      it 'is case-insensitive (YES)' do
        set_env('TURNDOWN_ENABLED', 'YES')
        expect(provider.active_state).to be_a(Turndown::MaintenanceState)
      end
    end

    context 'when TURNDOWN_ENABLED=1' do
      before { set_env('TURNDOWN_ENABLED', '1') }

      it 'sets reason from TURNDOWN_REASON' do
        set_env('TURNDOWN_REASON', 'Deploying now')
        expect(provider.active_state.reason).to eq('Deploying now')
      end

      it 'falls back to config default reason when TURNDOWN_REASON is not set' do
        expect(provider.active_state.reason).to eq(Turndown.config.default_reason)
      end

      it 'parses TURNDOWN_ALLOWED_IPS into an array' do
        set_env('TURNDOWN_ALLOWED_IPS', '10.0.0.1,192.168.1.0/24')
        expect(provider.active_state.allowed_ips).to eq(['10.0.0.1', '192.168.1.0/24'])
      end

      it 'falls back to config default allowed_ips when not set' do
        expect(provider.active_state.allowed_ips).to eq(Turndown.config.default_allowed_ips)
      end

      it 'parses TURNDOWN_ALLOWED_PATHS into an array' do
        set_env('TURNDOWN_ALLOWED_PATHS', '/health,/ping')
        expect(provider.active_state.allowed_paths).to eq(['/health', '/ping'])
      end

      it 'falls back to config default allowed_paths when not set' do
        expect(provider.active_state.allowed_paths).to eq(Turndown.config.default_allowed_paths)
      end

      it 'sets response_code as an integer from TURNDOWN_RESPONSE_CODE' do
        set_env('TURNDOWN_RESPONSE_CODE', '418')
        expect(provider.active_state.response_code).to eq(418)
        expect(provider.active_state.response_code).to be_an(Integer)
      end

      it 'falls back to config default response_code when not set' do
        expect(provider.active_state.response_code).to eq(Turndown.config.default_response_code)
      end

      it 'sets retry_after from TURNDOWN_RETRY_AFTER' do
        set_env('TURNDOWN_RETRY_AFTER', '3600')
        expect(provider.active_state.retry_after).to eq('3600')
      end

      it 'falls back to config default retry_after when not set' do
        expect(provider.active_state.retry_after).to eq(Turndown.config.default_retry_after)
      end
    end

    context 'with a custom env_prefix' do
      before do
        Turndown.config.env_prefix = 'APP_MAINT'
        set_env('APP_MAINT_ENABLED', '1')
        set_env('APP_MAINT_REASON', 'Custom prefix reason')
      end

      it 'reads APP_MAINT_ENABLED instead of TURNDOWN_ENABLED' do
        expect(provider.active_state).to be_a(Turndown::MaintenanceState)
      end

      it 'reads APP_MAINT_REASON' do
        expect(provider.active_state.reason).to eq('Custom prefix reason')
      end

      it 'does not activate when the default TURNDOWN_ENABLED is set but not the custom prefix' do
        ENV.delete('APP_MAINT_ENABLED')
        set_env('TURNDOWN_ENABLED', '1')
        expect(provider.active_state).to be_nil
      end
    end

    context 'ENV is read fresh on each call (no caching)' do
      it 'reflects changes between successive calls' do
        expect(provider.active_state).to be_nil

        set_env('TURNDOWN_ENABLED', '1')
        expect(provider.active_state).to be_a(Turndown::MaintenanceState)

        ENV.delete('TURNDOWN_ENABLED')
        expect(provider.active_state).to be_nil
      end
    end
  end
end
