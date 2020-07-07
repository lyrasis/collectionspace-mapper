# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Authorities do
  describe '#build_authority_urn' do
    it 'generates authority urn' do
      name = "Jurgen Klopp!"
      type = 'personauthorities'
      subtype = 'person'
      expected = "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(JurgenKlopp1289035554)'Jurgen Klopp!'"
      expect(Authorities.build_authority_urn(type, subtype, name, anthro_cache)).to eq(expected)
    end
  end
end
