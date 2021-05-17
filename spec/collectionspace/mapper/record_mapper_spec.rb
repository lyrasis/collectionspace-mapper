# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::RecordMapper do
  let(:path) { 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_collectionobject.json' }
  let(:jsonmapper) { get_json_record_mapper(path) }
  let(:client) { anthro_client }
  let(:mapper) { mapr = described_class.new(mapper: jsonmapper, csclient: client) }

  it 'has expected instance variables' do
    expected = [:@xpath, :@config, :@xml_template, :@mappings, :@batchconfig, :@csclient, :@termcache].sort
    expect(mapper.instance_variables.sort).to eq(expected)
  end

  describe '#service_type' do
    context 'when initialized with authority mapper' do
      let(:path) { 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_citation-local.json' }
      it 'returns Authority module name' do
        expect(mapper.service_type).to eq(CS::Mapper::Authority)
      end
    end

    context 'when initialized with relationship mapper' do
      let(:path) { 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_authorityhierarchy.json' }
      it 'returns Relationship module name' do
        expect(mapper.service_type).to eq(CS::Mapper::Relationship)
      end
    end

    context 'when initialized with any other mapper' do
      it 'returns nil' do
        expect(mapper.service_type).to be_nil
      end
    end
  end

  describe '#termcache' do
    context 'when cache is not passed in at initialization', services_call: true do
      context 'when mapping an authority' do
        let(:path) { 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4-1-2_place-local.json' }
        it 'cache.search_identifiers = false' do
          expect(mapper.termcache.inspect).to include('@search_identifiers=false')
        end
      end
      context 'when mapping a non-authority' do
        it 'cache.search_identifiers = true' do
          expect(mapper.termcache.inspect).to include('@search_identifiers=true')
        end
      end
    end
  end
end
