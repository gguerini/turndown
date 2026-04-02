# frozen_string_literal: true

require 'spec_helper'

describe Turndown::MaintenancePage::Erb do
  describe 'class methods' do
    subject { Turndown::MaintenancePage::Erb }

    it 'has the correct media_types' do
      expect(subject.media_types).to eq(%w[text/html application/xhtml+xml])
    end

    it 'has the correct extension' do
      expect(subject.extension).to eq('html.erb')
    end
  end

  describe 'instance methods' do
    let(:reason) { nil }
    let(:instance) { Turndown::MaintenancePage::Erb.new(*[reason].compact) }
    subject { instance }

    describe '#reason' do
      context 'without a reason' do
        it 'returns an empty string' do
          expect(subject.reason).to eq('')
        end
      end

      context 'with a reason' do
        let(:reason) { "Just because.\nOkay!" }

        it 'wraps lines in <p> tags' do
          expect(subject.reason).to eq("<p>Just because.</p>\n<p>Okay!</p>")
        end
      end
    end

    describe '#rack_response' do
      let(:reason) { 'Oops!' }
      let(:code) { nil }
      let(:retry_after) { nil }
      let(:raw_response) { instance.rack_response(code, retry_after) }
      subject { Rack::MockResponse.new(*raw_response) }

      context 'without a code' do
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

        it 'has content-type of text/html' do
          expect(subject.content_type).to eq('text/html')
        end

        it 'has the expected content length' do
          expect(subject.content_length).to eq(1199)
        end

        it 'returns the body as an Array' do
          expect(raw_response[2]).to be_an(Array)
        end

        it 'body contains <html>' do
          expect(subject.body).to match('<html>')
        end

        it 'body contains the reason' do
          expect(subject.body).to match('Oops!')
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
