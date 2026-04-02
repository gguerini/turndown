# frozen_string_literal: true

require 'spec_helper'

describe Turndown::Configuration do
  let(:config) { Turndown::Configuration.new }
  subject { config }

  describe '#app_root' do
    it 'is a Pathname' do
      expect(subject.app_root).to be_a(Pathname)
    end

    it 'defaults to "."' do
      expect(subject.app_root.to_s).to eq('.')
    end

    it 'can be changed' do
      expect { subject.app_root = '/tmp' }
        .to change { subject.app_root }
        .from(Pathname.new('.'))
        .to(Pathname.new('/tmp'))
    end
  end

  describe '#named_maintenance_file_paths' do
    subject { config.named_maintenance_file_paths }

    it 'defaults to { default: "tmp/maintenance.yml" }' do
      expect(subject).to eq(default: 'tmp/maintenance.yml')
    end

    context 'when a string is given as a key' do
      before { config.named_maintenance_file_paths = { 'new' => 'tmp/new.yml' } }

      it 'converts the key to a symbol' do
        expect(subject).to have_key(:new)
      end
    end
  end

  describe '#maintenance_pages_path' do
    it 'defaults to "public"' do
      expect(subject.maintenance_pages_path).to eq('public')
    end

    it 'can be changed' do
      expect { subject.maintenance_pages_path = '/tmp' }
        .to change { subject.maintenance_pages_path }
        .from('public')
        .to('/tmp')
    end
  end

  describe '#default_maintenance_page' do
    it 'defaults to HTML page class' do
      expect(subject.default_maintenance_page).to eq(Turndown::MaintenancePage::HTML)
    end
  end

  describe '#default_reason' do
    it 'has the expected default reason' do
      expect(subject.default_reason).to eq(
        "The site is temporarily down for maintenance.\nPlease check back soon."
      )
    end
  end

  describe '#default_allowed_paths' do
    it 'defaults to an empty array' do
      expect(subject.default_allowed_paths).to eq([])
    end
  end

  describe '#default_response_code' do
    it 'defaults to 503' do
      expect(subject.default_response_code).to eq(503)
    end
  end

  describe '#default_retry_after' do
    it 'defaults to 7200' do
      expect(subject.default_retry_after).to eq(7200)
    end
  end

  describe '#env_prefix' do
    it 'defaults to "TURNDOWN"' do
      expect(subject.env_prefix).to eq('TURNDOWN')
    end

    it 'can be changed' do
      expect { subject.env_prefix = 'APP_MAINT' }
        .to change { subject.env_prefix }
        .from('TURNDOWN')
        .to('APP_MAINT')
    end
  end

  describe '#providers' do
    it 'defaults to [Provider::Env, Provider::File]' do
      expect(subject.providers).to eq([
        Turndown::Provider::Env,
        Turndown::Provider::File
      ])
    end

    it 'can be changed' do
      expect { subject.providers = [Turndown::Provider::File] }
        .to change { subject.providers }
        .from([Turndown::Provider::Env, Turndown::Provider::File])
        .to([Turndown::Provider::File])
    end
  end

  describe '#update' do
    context 'invalid settings' do
      let(:settings) { { bogus: 'blah' } }

      it 'raises ArgumentError' do
        expect { subject.update(settings) }.to raise_exception(ArgumentError)
      end
    end

    context 'valid settings' do
      let(:settings) { { app_root: '/tmp' } }

      it 'updates the setting' do
        expect { subject.update(settings) }
          .to change { subject.app_root.to_s }
          .from('.')
          .to('/tmp')
      end
    end

    context 'named_maintenance_file_paths' do
      let(:settings) { { named_maintenance_file_paths: { test: 'tmp/main_dir' } } }

      it 'updates named_maintenance_file_paths' do
        expect { subject.update(settings) }
          .to change { subject.named_maintenance_file_paths }
          .to(test: 'tmp/main_dir')
      end
    end
  end
end
