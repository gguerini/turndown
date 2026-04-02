# frozen_string_literal: true

require 'spec_helper'

describe Turndown::MaintenancePage do
  describe '.all' do
    its(:all) { should_not include Turndown::MaintenancePage::Base }
    its(:all) { should eql [Turndown::MaintenancePage::HTML, Turndown::MaintenancePage::Erb, Turndown::MaintenancePage::JSON] }
  end

  describe '.best_for' do
    let(:env) { Rack::MockRequest.env_for('/', 'HTTP_ACCEPT' => content_type) }
    subject { Turndown::MaintenancePage.best_for(env) }

    context 'with "*/*" accept header' do
      let(:content_type) { '*/*' }

      it { should eql Turndown::MaintenancePage::HTML }
    end

    context 'with "text/html" accept header' do
      let(:content_type) { 'text/html' }

      it { should eql Turndown::MaintenancePage::HTML }
    end

    context 'with "text/json" accept header' do
      let(:content_type) { 'text/json' }

      it { should eql Turndown::MaintenancePage::JSON }
    end

    context 'with "image/gif" accept header' do
      let(:content_type) { 'image/gif' }

      it { should eql Turndown::MaintenancePage::HTML }
    end
  end
end
