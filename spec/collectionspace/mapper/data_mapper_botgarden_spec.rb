# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = CollectionSpace::Mapper::DEFAULT_CONFIG
  end

  context 'botgarden profile' do
    before(:all) do
      @client = botgarden_client
      @cache = botgarden_cache
      populate_botgarden(@cache)
    end
    
    context 'pottag record' do
      before(:all) do
        @pottag_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_1_1_0-pottag.json')
        @pottag_handler = DataHandler.new(@pottag_mapper, @client, @cache, @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/botgarden/pottag1.json')
          @prepper = DataPrepper.new(@datahash, @pottag_handler)
          @mapper = DataMapper.new(@prepper.prep, @pottag_handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('botgarden/pottag1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @pottag_handler.mapper[:mappings])
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

    context 'propagation record' do
      before(:all) do
        @propagation_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_1_1_0-propagation.json')
        @propagation_handler = DataHandler.new(@propagation_mapper, @client, @cache, @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/botgarden/propagation1.json')
          @prepper = DataPrepper.new(@datahash, @propagation_handler)
          @mapper = DataMapper.new(@prepper.prep, @propagation_handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('botgarden/propagation1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @propagation_handler.mapper[:mappings])
        end
        it 'does not map unexpected fields' do
          diff = @mapped_xpaths - @fixture_xpaths
          puts diff
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
    
    context 'taxon record' do
      before(:all) do
        @taxon_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_1_1_0-taxon.json')
        @taxon_handler = DataHandler.new(@taxon_mapper, @client, @cache, @config)
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
