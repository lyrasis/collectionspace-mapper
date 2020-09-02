# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = {
      delimiter: ';',
      subgroup_delimiter: '^^'
    }
  end

  context 'bonsai profile' do
    before(:all) do
      @cache = bonsai_cache
      populate_bonsai(@cache)
    end
    
    context 'objectexit record' do
      before(:all) do
        @rm_bonsai_oe = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/bonsai/bonsai_4_1_0-objectexit.json')
        @handler = DataHandler.new(record_mapper: @rm_bonsai_oe, cache: @cache, client: bonsai_client, config: @config)
      end

      context 'record 1' do
        before(:all) do
          @datahash = get_datahash(path: 'spec/fixtures/files/datahashes/bonsai/objectexit1.json')
          @prepper = DataPrepper.new(@datahash, @handler)
          @mapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
          @mapped_doc = remove_namespaces(@mapper.response.doc)
          @mapped_xpaths = list_xpaths(@mapped_doc)
          @fixture_doc = get_xml_fixture('bonsai/objectexit1.xml')
          @fixture_xpaths = test_xpaths(@fixture_doc, @handler.mapper[:mappings])
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
