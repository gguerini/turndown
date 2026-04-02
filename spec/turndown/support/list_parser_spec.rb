# frozen_string_literal: true

require 'spec_helper'

describe Turndown::Support::ListParser do
  describe '.call' do
    it 'returns an empty array for nil' do
      expect(described_class.call(nil)).to eq([])
    end

    it 'returns an empty array for an empty string' do
      expect(described_class.call('')).to eq([])
    end

    it 'splits a comma-separated string into an array' do
      expect(described_class.call('a,b,c')).to eq(%w[a b c])
    end

    it 'trims whitespace around values' do
      expect(described_class.call('a, b, c')).to eq(%w[a b c])
    end

    it 'preserves escaped commas within values' do
      expect(described_class.call('a\,b,c')).to eq(['a,b', 'c'])
    end
  end
end
