# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Response do
  before(:all) do
    @config = Mapper::DEFAULT_CONFIG
    @client = botgarden_client
    @cache = botgarden_cache
    populate_botgarden(@cache)
    @mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_1_1_0-taxon.json')
    @handler = DataHandler.new(record_mapper: @mapper, cache: @cache, client: @client, config: @config)
  end

  describe '#valid?' do
    context 'when there are no errors' do
      it 'returns true' do
        data = { 'termDisplayName' => 'Tanacetum' }
        validation_response = @handler.validate(data)
        expect(validation_response.valid?).to be true
      end
    end
    context 'when there is one or more errors' do
      it 'returns false' do
        data = { 'taxonName' => 'Tanacetum' }
        validation_response = @handler.validate(data)
        expect(validation_response.valid?).to be false
      end
    end
  end

  describe '#normal' do
    context 'when response_mode = normal in config' do
      before(:all) do
        data = { 'termDisplayName' => 'Tanacetum;Tansy', 'termStatus' => 'made up' }
        vresponse = @handler.validate(data)
        @response = @handler.process(data, vresponse)
      end
      it 'returns Mapper::Response with populated doc' do
        expect(@response.doc).to be_a(Nokogiri::XML::Document)
      end
      it 'returns Mapper::Response with populated warnings' do
        expect(@response.warnings).not_to be_empty
      end
      xit 'returns Mapper::Response with populated identifier' do
        expect(@response.identifier).not_to be_empty
      end
      it 'returns Mapper::Response with unpopulated orig_data' do
        expect(@response.orig_data).to be_empty
      end
      it 'returns Mapper::Response with unpopulated merged_data' do
        expect(@response.merged_data).to be_empty
      end
      it 'returns Mapper::Response with unpopulated split_data' do
        expect(@response.split_data).to be_empty
      end
      it 'returns Mapper::Response with unpopulated transformed_data' do
        expect(@response.transformed_data).to be_empty
      end
      it 'returns Mapper::Response with unpopulated combined_data' do
        expect(@response.combined_data).to be_empty
      end
    end
  end
  
  context 'botgarden profile' do
    context 'taxon record' do
      before(:all) do
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/botgarden/taxon1.json')
          @prepper = DataPrepper.new(@datahash, @taxon_handler)
          @mapper = DataMapper.new(@prepper.prep, @taxon_handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('botgarden/taxon1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @taxon_handler.mapper[:mappings])
        end
        it 'does not map unexpected fields' do
          diff = @mapped_xpaths - @fixture_xpaths
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          @fixture_xpaths.each do |xpath|
            fixture_node = standardize_value(@fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(@mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end
  end
end
