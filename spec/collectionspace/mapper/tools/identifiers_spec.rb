# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Identifiers do
  describe '#short_identifier' do
    it 'generates identifier' do
      name = "Jurgen Klopp!"
      short_identifier = "JurgenKlopp1289035554"
      expect(Identifiers.short_identifier(name)).to eq short_identifier
    end
  end
end
