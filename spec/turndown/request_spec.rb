# frozen_string_literal: true

require 'spec_helper'

describe Turndown::Request do
  let(:path) { '/' }
  let(:ip) { '127.0.0.1' }
  let(:env) { Rack::MockRequest.env_for(path, 'REMOTE_ADDR' => ip) }
  let(:request) { Turndown::Request.new(env) }

  describe '#allowed?' do
    # A minimal state with no allowed paths or IPs — nothing is allowed through.
    let(:settings) do
      Turndown::MaintenanceState.new(
        reason:        'Maintenance',
        allowed_paths: [],
        allowed_ips:   [],
        response_code: 503,
        retry_after:   nil
      )
    end
    subject { request.allowed?(settings) }

    context 'with empty allowed_paths and allowed_ips' do
      it { should be false }
    end

    context 'with allowed_paths and allowed_ips configured' do
      # Mirrors the fixture: allowed_paths: [/uuddlrlrba.*], allowed_ips: [10.0.0.42, 192.168.1.0/24]
      let(:settings) do
        Turndown::MaintenanceState.new(
          reason:        'Maintenance',
          allowed_paths: ['/uuddlrlrba.*'],
          allowed_ips:   ['10.0.0.42', '192.168.1.0/24'],
          response_code: 503,
          retry_after:   nil
        )
      end

      context 'request for /letmein (no path or IP match)' do
        it { should be false }
      end

      context 'request for /uuddlrlrbastart (matches allowed path)' do
        let(:path) { '/uuddlrlrbastart' }
        it { should be true }
      end

      context 'request from 42.42.40.40 (not in allowed IPs)' do
        let(:ip) { '42.42.40.40' }
        it { should be false }
      end

      context 'request from 10.0.0.42 (exact match in allowed IPs)' do
        let(:ip) { '10.0.0.42' }
        it { should be true }
      end

      context 'request from 192.168.1.42 (within allowed CIDR range)' do
        let(:ip) { '192.168.1.42' }
        it { should be true }
      end
    end
  end
end
