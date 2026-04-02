# frozen_string_literal: true

require 'spec_helper'

describe Turndown::MaintenanceFile do
  let(:filename) { 'maintenance' }
  let(:path) { File.expand_path("../../fixtures/#{filename}.yml", __FILE__) }
  let(:maint_file) { Turndown::MaintenanceFile.new(path) }
  subject { maint_file }

  context 'with a missing file' do
    let(:filename) { 'nope' }

    it { expect(subject.exists?).to be false }
    it { expect(subject.reason).to eql "The site is temporarily down for maintenance.\nPlease check back soon." }
    it { expect(subject.allowed_paths).to eql [] }
    it { expect(subject.allowed_ips).to eql [] }
    it { expect(subject.response_code).to eql 503 }
    it { expect(subject.retry_after).to eql 7200 }
  end

  context 'with an existant file' do
    it { expect(subject.exists?).to be true }
    it { expect(subject.reason).to eql 'Oopsie!' }
    it { expect(subject.allowed_paths).to eql ['/uuddlrlrba.*'] }
    it { expect(subject.allowed_ips).to eql ['10.0.0.42', '192.168.1.0/24'] }
    it { expect(subject.response_code).to eql 418 }
    it { expect(subject.retry_after).to eql 3600 }

    describe '#to_h' do
      let(:hash) { maint_file.to_h }

      it { expect(maint_file.to_h).to be_a Hash }
      it { expect(hash.keys).to eql [:reason, :allowed_paths, :allowed_ips, :response_code, :retry_after] }
      it { expect(hash[:reason]).to eql 'Oopsie!' }
      it { expect(hash[:allowed_paths]).to eql ['/uuddlrlrba.*'] }
      it { expect(hash[:allowed_ips]).to eql ['10.0.0.42', '192.168.1.0/24'] }
      it { expect(hash[:response_code]).to eql 418 }
      it { expect(hash[:retry_after]).to eql 3600 }
    end

    describe '#to_yaml' do
      let(:yaml) { YAML.safe_load(maint_file.to_yaml) }
      subject { yaml }

      it { expect(maint_file.to_yaml).to be_a String }
      it { expect(yaml.keys).to eql ['reason', 'allowed_paths', 'allowed_ips', 'response_code', 'retry_after'] }
      it { expect(yaml['reason']).to eql 'Oopsie!' }
      it { expect(yaml['allowed_paths']).to eql ['/uuddlrlrba.*'] }
      it { expect(yaml['allowed_ips']).to eql ['10.0.0.42', '192.168.1.0/24'] }
      it { expect(yaml['response_code']).to eql 418 }
      it { expect(yaml['retry_after']).to eql 3600 }
    end
  end

  describe '#write' do
    let(:path) { '/tmp/bogus' }

    it 'writes the file' do
      file = double('file')
      expect(File).to receive(:open).with('/tmp/bogus', 'w').and_yield(file)
      expect(file).to receive(:write).with(maint_file.to_yaml)

      maint_file.write
    end
  end

  describe '#delete' do
    it 'deletes the file' do
      expect(File).to receive(:delete).with(path)
      maint_file.delete
    end
  end

  describe '#import' do
    let(:env_vars) { {} }
    before { maint_file.import_env_vars(env_vars) }

    it { expect(maint_file.import_env_vars({})).to be true }

    context 'with reason set' do
      let(:env_vars) { { 'reason' => 'I made a boo boo' } }
      it { expect(maint_file.reason).to eql 'I made a boo boo' }
    end

    context 'with allowed_paths set' do
      let(:env_vars) { { 'allowed_paths' => 'some/path,other/path' } }
      it { expect(maint_file.allowed_paths).to eql ['some/path', 'other/path'] }
    end

    context 'with allowed_ips set' do
      let(:env_vars) { { 'allowed_ips' => '10.0.0.1/24,127.0.0.1' } }
      it { expect(maint_file.allowed_ips).to eql ['10.0.0.1/24', '127.0.0.1'] }
    end

    context 'with response_code set' do
      let(:env_vars) { { 'response_code' => 418 } }
      it { expect(maint_file.response_code).to eql 418 }
    end

    context 'with retry_after set' do
      let(:env_vars) { { 'retry_after' => 3600 } }
      it { expect(maint_file.retry_after).to eql 3600 }
    end
  end

  describe '.find' do
    subject { Turndown::MaintenanceFile.find }

    context 'when a file exists' do
      before { Turndown.config.named_maintenance_file_paths = { fixture: 'spec/fixtures/maintenance.yml' } }
      it { should be_a Turndown::MaintenanceFile }
    end

    context 'when no file exists' do
      before { Turndown.config.named_maintenance_file_paths = { nope: 'spec/fixtures/nope.yml' } }
      it { should be_nil }
    end
  end

  describe '.named' do
    subject { Turndown::MaintenanceFile.named(name) }

    before { Turndown.config.named_maintenance_file_paths = { valid: 'spec/fixtures/nope.yml' } }

    context 'when a valid name' do
      let(:name) { :valid }
      it { should be_a Turndown::MaintenanceFile }
    end

    context 'when an invalid name' do
      let(:name) { :invalid }
      it { should be_nil }
    end
  end

  describe '.default' do
    subject { Turndown::MaintenanceFile.default }
    it { should be_a Turndown::MaintenanceFile }
  end
end
