# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Identifiers do
  describe '#short_identifier' do
    it 'generates hashed short identifiers for authorities' do
      authorities = {
        'Jurgen Klopp!' => 'JurgenKlopp1289035554',
        'Achillea millefolium' => 'Achilleamillefolium1482849582'
      }

      authorities.each do |term, id|
        expect(CollectionSpace::Mapper::Tools::Identifiers.short_identifier(term, :authority)).to eq(id)
      end
    end
    it 'generates non-hashed short identifiers for vocabularies' do
      authorities = {
        'Jurgen Klopp!' => 'JurgenKlopp',
        'Achillea millefolium' => 'Achilleamillefolium'
      }

      authorities.each do |term, id|
        expect(CollectionSpace::Mapper::Tools::Identifiers.short_identifier(term, :vocabulary)).to eq(id)
      end
    end
  end
end
