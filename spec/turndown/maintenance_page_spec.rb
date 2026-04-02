# frozen_string_literal: true

require 'spec_helper'

describe Turndown::MaintenancePage do
  describe '.all' do
    subject { described_class.all }

    it 'does not include Base' do
      expect(subject).not_to include(Turndown::MaintenancePage::Base)
    end

    it 'includes HTML, Erb, and JSON in that order' do
      expect(subject).to eq([
        Turndown::MaintenancePage::HTML,
        Turndown::MaintenancePage::Erb,
        Turndown::MaintenancePage::JSON
      ])
    end
  end

  describe '.best_for' do
    let(:env) { Rack::MockRequest.env_for('/', 'HTTP_ACCEPT' => content_type) }
    subject { Turndown::MaintenancePage.best_for(env) }

    context 'with "*/*" accept header' do
      let(:content_type) { '*/*' }
      it { should eq(Turndown::MaintenancePage::HTML) }
    end

    context 'with "text/html" accept header' do
      let(:content_type) { 'text/html' }
      it { should eq(Turndown::MaintenancePage::HTML) }
    end

    context 'with "text/json" accept header' do
      let(:content_type) { 'text/json' }
      it { should eq(Turndown::MaintenancePage::JSON) }
    end

    context 'with "application/json" accept header' do
      let(:content_type) { 'application/json' }
      it { should eq(Turndown::MaintenancePage::JSON) }
    end

    context 'with "application/json, text/html" accept header (html wins)' do
      let(:content_type) { 'application/json, text/html' }
      it { should eq(Turndown::MaintenancePage::HTML) }
    end

    context 'with "image/gif" accept header (falls back to HTML)' do
      let(:content_type) { 'image/gif' }
      it { should eq(Turndown::MaintenancePage::HTML) }
    end
  end
end
