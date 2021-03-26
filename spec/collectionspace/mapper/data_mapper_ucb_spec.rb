# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = {delimiter: "|",
               subgroup_delimiter: "^^",
               response_mode: "normal",
               force_defaults: false,
               default_values: {
                 'objectNameType' => 'simple',
                 'objectNameCurrency' => 'current',
                 'objectNameLevel' => 'whole',
                 'objectNameLanguageRefname' => "urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(languages):item:name(eng)'English'",
                 'inscriptionContentLanguageRefname' => "urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(languages):item:name(eng)'English'",
                 'contentLanguageRefname' => "urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(languages):item:name(eng)'English'",
                 'titleLanguageRefname' => "urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(languages):item:name(eng)'English'",
                 'titleTranslationLanguageRefname' => "urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(languages):item:name(eng)'English'",
                 'publishToRefname' => "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(none)'None'",
                 'inventoryStatusRefname' => "urn:cspace:core.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'unknown'",
                 'ownershipPriceCurrencyRefname' => "urn:cspace:pahma.cspace.berkeley.edu:vocabularies:name(currency):item:name(usd)'US Dollar ($)'",
                 'isComponent' => 'no'
               }
              }
  end

  context 'pahma profile' do
    before(:all) do
      @client = pahma_client
      @cache = pahma_cache
    end
  
    context 'collectionobject record' do
      before(:all) do
        @objmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/ucb_pahma_nagpra-collectionobject.json')
        @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @objmapper,
                                                            client: @client,
                                                            cache: @cache,
                                                            config: @config)
      end
      context 'record 2' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/ucb/ucb_pahma_nagpra_2.json')
          @prepper = CollectionSpace::Mapper::DataPrepper.new(@datahash, @handler)
          @mapper = CollectionSpace::Mapper::DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_blank_structured_dates(remove_namespaces(@mapper.response.doc))
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('ucb/ucb_pahma_nagpra_2.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper.mappings)
        end
        it 'does not map unexpected fields' do
          diff = @mapped_xpaths - @fixture_xpaths
          # puts @fixture_doc
          # puts 'UNEXPECTED FIELDS'
          # puts diff
          expect(diff).to eq([])
        end

        it 'maps as expected' do
          #puts @mapped_doc
          @fixture_xpaths.each do |xpath|
            #puts xpath
            fixture_node = standardize_value(@fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(@mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end
      end
    end
  end
end
