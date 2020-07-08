# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper do
  let(:rc) { anthro_cache }
  
  it 'has a version number' do
    expect(CollectionSpace::Mapper::VERSION).not_to be nil
  end

  it 'can create anthro refcache' do
    expect(rc).to be_a(CollectionSpace::RefCache)  
  end

  it 'gets config constants' do
    expect(Mapper::CONFIG[:delim]).to eq(';')
  end

  context 'when constant overridden by test' do
    before(:all) { Mapper::CONFIG[:delim] = '||' }
    after(:all) { Mapper::CONFIG[:delim] = ';' }
    it 'the override works' do
      expect(Mapper::CONFIG[:delim]).to eq('||')
    end
  end

  context 'when reading in JSON RecordMapper file' do
    it 'returns a Hash' do
      path = 'spec/fixtures/files/anthro_4_0_0-collectionobject.json'
      h = get_json_record_mapper(path: path)
      expect(h).to be_a(Hash)
    end
  end
end
