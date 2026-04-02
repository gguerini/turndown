# frozen_string_literal: true

require 'spec_helper'

describe Turndown::MaintenanceState do
  describe '#initialize' do
    subject do
      described_class.new(
        reason: 'Down for work',
        allowed_paths: ['/health'],
        allowed_ips: ['10.0.0.1'],
        response_code: '503',
        retry_after: 3600
      )
    end

    it 'sets reason' do
      expect(subject.reason).to eq('Down for work')
    end

    it 'sets allowed_paths as an array' do
      expect(subject.allowed_paths).to eq(['/health'])
    end

    it 'sets allowed_ips as an array' do
      expect(subject.allowed_ips).to eq(['10.0.0.1'])
    end

    it 'coerces response_code to an Integer' do
      expect(subject.response_code).to eq(503)
      expect(subject.response_code).to be_an(Integer)
    end

    it 'sets retry_after' do
      expect(subject.retry_after).to eq(3600)
    end

    context 'when allowed_paths is nil' do
      subject do
        described_class.new(
          reason: 'x', allowed_paths: nil, allowed_ips: nil,
          response_code: 503, retry_after: nil
        )
      end

      it 'returns an empty array for allowed_paths' do
        expect(subject.allowed_paths).to eq([])
      end

      it 'returns an empty array for allowed_ips' do
        expect(subject.allowed_ips).to eq([])
      end
    end

    context 'when allowed_paths is a single value (not an array)' do
      subject do
        described_class.new(
          reason: 'x', allowed_paths: '/health', allowed_ips: '10.0.0.1',
          response_code: 503, retry_after: nil
        )
      end

      it 'wraps allowed_paths in an array' do
        expect(subject.allowed_paths).to eq(['/health'])
      end

      it 'wraps allowed_ips in an array' do
        expect(subject.allowed_ips).to eq(['10.0.0.1'])
      end
    end
  end

  describe '.from_defaults' do
    context 'with no overrides' do
      subject { described_class.from_defaults }

      it 'uses the configured default reason' do
        expect(subject.reason).to eq(Turndown.config.default_reason)
      end

      it 'uses the configured default allowed_paths' do
        expect(subject.allowed_paths).to eq(Turndown.config.default_allowed_paths)
      end

      it 'uses the configured default allowed_ips' do
        expect(subject.allowed_ips).to eq(Turndown.config.default_allowed_ips)
      end

      it 'uses the configured default response_code' do
        expect(subject.response_code).to eq(Turndown.config.default_response_code)
      end

      it 'uses the configured default retry_after' do
        expect(subject.retry_after).to eq(Turndown.config.default_retry_after)
      end
    end

    context 'with overrides provided' do
      subject do
        described_class.from_defaults(
          reason: 'Custom reason',
          allowed_paths: ['/ping'],
          response_code: 418
        )
      end

      it 'uses the overridden reason' do
        expect(subject.reason).to eq('Custom reason')
      end

      it 'uses the overridden allowed_paths' do
        expect(subject.allowed_paths).to eq(['/ping'])
      end

      it 'uses the overridden response_code' do
        expect(subject.response_code).to eq(418)
      end

      it 'falls back to config default for non-overridden keys' do
        expect(subject.retry_after).to eq(Turndown.config.default_retry_after)
      end
    end

    context 'when an override value is nil' do
      subject do
        described_class.from_defaults(reason: nil, response_code: nil)
      end

      it 'falls back to the config default for reason' do
        expect(subject.reason).to eq(Turndown.config.default_reason)
      end

      it 'falls back to the config default for response_code' do
        expect(subject.response_code).to eq(Turndown.config.default_response_code)
      end
    end
  end
end
