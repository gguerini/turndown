# frozen_string_literal: true

require 'spec_helper'

describe Turndown::MaintenancePage::JSON do
  describe 'class methods' do
    subject { Turndown::MaintenancePage::JSON }

    it 'has the correct media_types' do
      expect(subject.media_types).to eq(%w[
        application/json text/json application/x-javascript
        text/javascript text/x-javascript text/x-json
      ])
    end

    it 'has the correct extension' do
      expect(subject.extension).to eq('json')
    end
  end

  describe 'instance methods' do
    let(:reason) { nil }
    let(:instance) { Turndown::MaintenancePage::JSON.new(*[reason].compact) }
    subject { instance }

    it 'exposes media_types on an instance' do
      expect(subject.media_types).to eq(%w[
        application/json text/json application/x-javascript
        text/javascript text/x-javascript text/x-json
      ])
    end

    it 'exposes extension on an instance' do
      expect(subject.extension).to eq('json')
    end

    describe '#reason' do
      context 'without a reason' do
        it 'returns an empty JSON string' do
          expect(subject.reason).to eq('""')
        end
      end

      context 'with a reason' do
        let(:reason) { "Just because.\nOkay!" }

        it 'returns the reason as a JSON string literal' do
          expect(subject.reason).to eq('"Just because.\nOkay!"')
        end
      end
    end

    describe '#rack_response' do
      let(:reason) { 'Oops!' }
      let(:code) { nil }
      let(:retry_after) { nil }
      let(:raw_response) { instance.rack_response(code, retry_after) }
      subject { Rack::MockResponse.new(*raw_response) }

      def parsed_json
        ::JSON.parse(subject.body)
      end

      context 'without code and retry_after' do
        it 'returns an Array' do
          expect(raw_response).to be_an(Array)
        end

        it 'returns status 503' do
          expect(subject.status).to eq(503)
        end

        it 'has a headers Hash' do
          expect(subject.headers).to be_a(Hash)
        end

        it 'has a content-type header' do
          expect(subject.headers).to have_key('content-type')
        end

        it 'has a content-length header' do
          expect(subject.headers).to have_key('content-length')
        end

        it 'does not have a retry-after header' do
          expect(subject.headers).not_to have_key('retry-after')
        end

        it 'has content-type of application/json' do
          expect(subject.content_type).to eq('application/json')
        end

        it 'body parses as a JSON Hash' do
          expect(parsed_json).to be_a(Hash)
        end

        it 'JSON body has an "error" key' do
          expect(parsed_json).to have_key('error')
        end

        it 'JSON body has a "message" key' do
          expect(parsed_json).to have_key('message')
        end

        it 'JSON body message equals the reason' do
          expect(parsed_json['message']).to eq('Oops!')
        end
      end

      context 'with a code' do
        let(:code) { 418 }

        it 'returns status 418' do
          expect(subject.status).to eq(418)
        end
      end

      context 'with retry_after' do
        let(:retry_after) { 3600 }

        it 'includes a retry-after header' do
          expect(subject.headers).to include('retry-after' => '3600')
        end
      end
    end
  end
end
