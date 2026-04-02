# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

describe 'Rack::Turndown' do
  let(:endpoint) { TestApp.new }
  let(:app) { Rack::Lint.new(Rack::Turndown.new(endpoint)) }

  around(:each) do |example|
    keys_before = ENV.keys.dup
    example.run
    (ENV.keys - keys_before).each { |k| ENV.delete(k) }
  end

  context 'when no providers are active' do
    it 'passes through to the app and returns 200' do
      response = get('/any_path')
      expect(response.status).to eq(200)
    end

    it 'returns the app body' do
      response = get('/any_path')
      expect(response.body).to eq('Hello World!')
    end
  end

  context 'when TURNDOWN_ENABLED=1' do
    before { ENV['TURNDOWN_ENABLED'] = '1' }

    it 'returns 503 for a normal request' do
      response = get('/any_path')
      expect(response.status).to eq(503)
    end

    it 'does not return the app body' do
      response = get('/any_path')
      expect(response.body).not_to eq('Hello World!')
    end

    it 'uses a lowercase content-type header' do
      response = get('/any_path')
      # Rack::MockResponse exposes headers by their original (lowercased) key
      expect(response.headers['content-type']).to eq('text/html')
    end

    context 'with TURNDOWN_ALLOWED_IPS matching the request IP' do
      before { ENV['TURNDOWN_ALLOWED_IPS'] = '10.0.0.42' }

      it 'allows the request through (returns 200)' do
        response = get('/any_path', {}, 'REMOTE_ADDR' => '10.0.0.42')
        expect(response.status).to eq(200)
      end

      it 'still blocks a non-matching IP' do
        response = get('/any_path', {}, 'REMOTE_ADDR' => '10.0.0.99')
        expect(response.status).to eq(503)
      end
    end
  end

  context 'file-based activation' do
    around(:each) do |example|
      Dir.mktmpdir do |tmpdir|
        @maintenance_file_path = File.join(tmpdir, 'maintenance.yml')
        Turndown.config.named_maintenance_file_paths = { default: @maintenance_file_path }
        example.run
      end
    end

    context 'when a maintenance file exists' do
      before do
        File.write(@maintenance_file_path, <<~YAML)
          reason: File-based maintenance
          response_code: 503
        YAML
      end

      it 'returns 503' do
        response = get('/any_path')
        expect(response.status).to eq(503)
      end

      it 'renders the reason from the file' do
        response = get('/any_path')
        expect(response.body).to include('File-based maintenance')
      end
    end

    context 'when ENV and file are both active' do
      before do
        ENV['TURNDOWN_ENABLED'] = '1'
        ENV['TURNDOWN_REASON']  = 'ENV reason wins'
        File.write(@maintenance_file_path, "reason: File reason\n")
      end

      it 'returns 503' do
        response = get('/any_path')
        expect(response.status).to eq(503)
      end

      it 'uses the reason from ENV (ENV provider checked first)' do
        response = get('/any_path')
        expect(response.body).to include('ENV reason wins')
        expect(response.body).not_to include('File reason')
      end
    end
  end

  context 'when providers is configured to File only' do
    before do
      Turndown.config.providers = [Turndown::Provider::File]
      ENV['TURNDOWN_ENABLED'] = '1'
    end

    it 'ignores ENV vars entirely and returns 200' do
      response = get('/any_path')
      expect(response.status).to eq(200)
    end
  end
end
