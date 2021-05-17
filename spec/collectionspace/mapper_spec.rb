# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper do
  it 'has a version number' do
    expect(CollectionSpace::Mapper::VERSION).not_to be nil
  end

  describe '#setup_data' do
    context 'when passed a CollectionSpace::Mapper::Response' do
      it 'returns that Response' do
        response = CollectionSpace::Mapper::Response.new({ 'objectNumber'=>'123' })
        expect(CollectionSpace::Mapper::setup_data(response)).to eq(response)
      end
    end
    context 'when passed a Hash' do
      before(:all) do
        @data = { 'objectNumber'=>'123' }
        @response = CollectionSpace::Mapper::setup_data(@data)
      end
      it 'returns a CollectionSpace::Mapper::Response' do
        expect(@response).to be_a(CollectionSpace::Mapper::Response)
      end
      it 'sets Hash as Response.orig_data' do
        expect(@response.orig_data).to eq(@data)
      end
    end
    context 'when passed other class of object' do
      it 'returns a CollectionSpace::Mapper::Response' do
        data = ['objectNumber', '123']
        expect{ CollectionSpace::Mapper::setup_data(data) }.to raise_error(CollectionSpace::Mapper::Errors::UnprocessableDataError, 'Cannot process a Array. Need a Hash or Mapper::Response')
      end
    end
  end

  context 'when testing' do
    let(:rc) { anthro_cache }
    let(:mapperpath) { 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json' }
    
    
    it 'can create anthro refcache' do
      expect(rc).to be_a(CollectionSpace::RefCache)  
    end

    it 'getting json record mapper returns a Hash' do
      hash = get_json_record_mapper(mapperpath)
      expect(hash).to be_a(Hash)
    end

    it 'getting RecordMapper returns a RecordMapper object' do
      obj = get_record_mapper_object(mapperpath)
      expect(obj).to be_a(CS::Mapper::RecordMapper)
    end
  end
end
