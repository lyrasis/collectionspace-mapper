# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = {
      delimiter: ';',
      subgroup_delimiter: '^^'
    }
  end

  context 'anthro profile' do
    before(:all) do
      populate_anthro(anthro_cache)
    end
    
    context 'collectionobject record' do
      before(:all) do
        @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_0/anthro/anthro_4_0_0-collectionobject.json')
        @dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, client: anthro_client, config: @config)
      end
      # record 1 was used for testing default value merging, transformations, etc.
      # we start with record 2 to purely test mapping functionality
      context 'rec 2' do
        let(:datahash) { get_datahash(path: 'spec/fixtures/files/datahashes/anthro/collectionobject2.json') }
        let(:prepper) { DataPrepper.new(datahash, @dh) }
        let(:prepped) { prepper.prep }
        let(:dm) { DataMapper.new(prepped, @dh, prepper.xphash) }
        let(:mapped_doc) { remove_namespaces(dm.response.doc) }
        let(:mapped_xpaths) { list_xpaths(mapped_doc) }
        let(:fixture_doc) { get_xml_fixture('anthro/collectionobject1.xml') }
        let(:fixture_xpaths) { test_xpaths(fixture_doc, @dh.mapper[:mappings]) }
        it 'maps as expected' do
          fixture_xpaths.each do |xpath|
            #            puts resdoc
            #            puts xpath
            fixture_node = standardize_value(fixture_doc.xpath(xpath).text)
            mapped_node = standardize_value(mapped_doc.xpath(xpath).text)
            expect(mapped_node).to eq(fixture_node)
          end
        end

        it 'does not map unexpected fields' do
          puts 'RESULT XPATHS'
          puts mapped_xpaths

          puts "\n\nFIXTURE XPATHS"
          puts fixture_xpaths
          
          diff = mapped_xpaths - fixture_xpaths
          puts "\n\nDIFF"
          puts diff

#          pp(result_doc)

          expect(diff).to eq([])
        end
      end
    end
  end
end
