# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = CollectionSpace::Mapper::DEFAULT_CONFIG.merge({delimiter: ';'})
  end

  context 'core profile' do
    before(:all) do
      @client = core_client
      @cache = core_cache
      populate_core(@cache)
    end

    context 'non-hierarchical relationship record' do
      # NOTE!
      # These tests are prone to failing if one of the records used in the test in core.dev is deleted
      # If a UUID is expected but you get blank, recreate the record in core.dev, rerun the test to
      #   get the UUID for the new record, and replace the old UUID in both fixture XML files used. 
      before(:all) do
        @nhr_mapper = get_json_record_mapper(
          'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_nonhierarchicalrelationship.json'
        )
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @nhr_mapper,
                                                            client: @client,
                                                            cache: @cache,
                                                            config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/nonHierarchicalRelationship1.json')
          @response = @handler.process(@datahash)
          @mapped_doc1 = remove_namespaces(@response[0].doc)
          @mapped_doc2 = remove_namespaces(@response[1].doc)
          @mapped_xpaths1 = list_xpaths(@mapped_doc1)
          @mapped_xpaths2 = list_xpaths(@mapped_doc2)
          @fixture_doc1 = get_xml_fixture('core/nonHierarchicalRelationship1A.xml')
          @fixture_xpaths1 = test_xpaths(@fixture_doc1, @handler.mapper.mappings)
          @fixture_doc2 = get_xml_fixture('core/nonHierarchicalRelationship1B.xml')
          @fixture_xpaths2 = test_xpaths(@fixture_doc2, @handler.mapper.mappings)
        end

        context 'with original data' do
          it 'sets response id field as expected' do
            expect(@response[0].identifier).to eq('2020.1.107 TEST (collectionobjects) -> LOC2020.1.24 (movements)')
          end
          
          it 'does not map unexpected fields' do
            diff = @mapped_xpaths1 - @fixture_xpaths1
            expect(diff).to eq([])
          end

          it 'maps as expected' do
            @fixture_xpaths1.each do |xpath|
              fixture_node = standardize_value(@fixture_doc1.xpath(xpath).text)
              mapped_node = standardize_value(@mapped_doc1.xpath(xpath).text)
              expect(mapped_node).to eq(fixture_node)
            end
          end
        end

        context 'with flipped data' do
          it 'sets response id field as expected' do
            expect(@response[1].identifier).to eq('LOC2020.1.24 (movements) -> 2020.1.107 TEST (collectionobjects)')
          end
          
          it 'does not map unexpected fields' do
            diff = @mapped_xpaths2 - @fixture_xpaths2
            expect(diff).to eq([])
          end

          it 'maps as expected' do
            @fixture_xpaths2.each do |xpath|
              fixture_node = standardize_value(@fixture_doc2.xpath(xpath).text)
              mapped_node = standardize_value(@mapped_doc2.xpath(xpath).text)
              expect(mapped_node).to eq(fixture_node)
            end
          end
        end
      end
    end

    context 'authority hierarchy record' do
      before(:all) do
        @ah_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_authorityhierarchy.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @ah_mapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/authorityHierarchy1.json')
#          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
#          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @response = @handler.process(@datahash)
          @mapped_doc = remove_namespaces(@response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/authorityHierarchy1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
        end

        it 'sets response id field as expected' do
          expect(@response.identifier).to eq('Cats > Siamese cats')
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

    context 'object hierarchy record' do
      before(:all) do
        @oh_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-object_hierarchy.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @oh_mapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/objectHierarchy1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/objectHierarchy1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
        end

        it 'sets response id field as expected' do
          expect(@mapper.response.identifier).to eq('2020.1.105 > 2020.1.1055')
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

    context 'acquisition record' do
      before(:all) do
        @acquisition_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-acquisition.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @acquisition_mapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/acquisition1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/acquisition1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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
    
    context 'collectionobject record' do
      before(:all) do
        @collectionobject_mapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-collectionobject.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @collectionobject_mapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/collectionobject1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/collectionobject1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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
    
    context 'conditioncheck record' do
      before(:all) do
        @conditioncheckmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-conditioncheck.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @conditioncheckmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/conditioncheck1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/conditioncheck1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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

    context 'conservation record' do
      before(:all) do
        @conservationmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-conservation.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @conservationmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/conservation1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/conservation1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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

    context 'exhibition record' do
      before(:all) do
        @exhibitionmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-exhibition.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @exhibitionmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/exhibition1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/exhibition1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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
    
    context 'group record' do
      before(:all) do
        @groupmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-group.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @groupmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/group1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/group1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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

    context 'intake record' do
      before(:all) do
        @intakemapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-intake.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @intakemapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/intake1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/intake1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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

    context 'loanin record' do
      before(:all) do
        @rm_core_co = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-loanin.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @rm_core_co, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/loanin1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/loanin1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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
    
    context 'loanout record' do
      before(:all) do
        @loanoutmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-loanout.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @loanoutmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/loanout1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/loanout1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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
    context 'movement record' do
      before(:all) do
        @movementmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-movement.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @movementmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/movement1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/movement1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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

    context 'media record' do
      before(:all) do
        @movementmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-media.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @movementmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/media1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/media1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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

    context 'objectexit record' do
      before(:all) do
        @objectexitmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-objectexit.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @objectexitmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/objectexit1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/objectexit1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
        end
        it 'does not map unexpected fields' do
          diff = @mapped_xpaths - @fixture_xpaths 
          expect(diff).to eq([]) 
        end

        it 'maps as expected' do
          @fixture_xpaths.each do |xpath|
            next if xpath.start_with?('/document/objectexit_common/exitDateGroup')
            fixture_node = standardize_value(@fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(@mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end

    context 'uoc record' do
      before(:all) do
        @uocmapper = get_json_record_mapper('spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-uoc.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @uocmapper, client: @client, cache: @cache, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/core/uoc1.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('core/uoc1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
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
