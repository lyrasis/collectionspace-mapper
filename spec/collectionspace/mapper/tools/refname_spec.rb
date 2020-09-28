# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::RefName do
  before(:all) do
    @cache = anthro_cache
    populate_anthro(@cache)
  end
  describe '#build' do
    it 'builds refname for authorities' do
      source_type = :authority
      type = 'personauthorities'
      subtype = 'person'
      term = 'Mary Poole'
      refname = "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(MaryPoole1796320156)'Mary Poole'"
      expect(CollectionSpace::Mapper::Tools::RefName.build(source_type, type, subtype, term, @cache)).to eq(refname)
    end
    it 'builds refname for vocabularies' do
      source_type = :vocabulary
      type = 'vocabularies'
      subtype = 'annotationtype'
      term = 'another term'
      refname = "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(anotherterm)'another term'"
      expect(CollectionSpace::Mapper::Tools::RefName.build(source_type, type, subtype, term, @cache)).to eq(refname)
    end
  end
end
