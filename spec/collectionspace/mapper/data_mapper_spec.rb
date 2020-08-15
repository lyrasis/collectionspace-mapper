# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    config = {
      delimiter: ';',
      subgroup_delimiter: '^^',
      transforms: {
        'collection' => {
          special: %w[downcase_value],
          replacements: [
            { find: ' ', replace: '-', type: :plain }
          ]
        },
        'ageRange' => {
          special: %w[downcase_value],
          replacements: [
            { find: ' - ', replace: '-', type: :plain }
          ]
        }
      },
      default_values: {
        'publishTo' => 'DPLA;Omeka',
        'collection' => 'library-collection'
      },
      force_defaults: false
    }

    @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/anthro_4_0_0-collectionobject.json')
    @dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, client: anthro_client, config: config)
    populate_anthro(@dh.cache)
    @prepper = DataPrepper.new(anthro_co_1, @dh)
    @prepped = @dh.prep(anthro_co_1)
    @dm = DataMapper.new(@prepped, @dh, @prepper.xphash)
  end

  describe '#doc' do
    it 'returns XML doc' do
      res = @dm.doc
      expect(res).to be_a(Nokogiri::XML::Document)
    end
  end

  describe '#response' do
    it 'returns Mapper::Response object' do
      res = @dm.response
      expect(res).to be_a(Mapper::Response)
    end
    it 'Mapper::Response.doc is XML document' do
      res = @dm.response.doc
      expect(res).to be_a(Nokogiri::XML::Document)
    end
  end
  
  describe '#add_namespaces' do
    it 'adds namespace definitions' do
      urihash = @dm.handler.mapper[:config][:ns_uri].clone
      urihash.transform_keys!{ |k| "ns2:#{k}" }
      docdefs = {}
      @dm.doc.xpath('/*/*').each do |ns|
        docdefs[ns.name] = ns.namespace_definitions.select{ |d| d.prefix == 'ns2' }.first.href
      end
      unused_keys = urihash.keys - docdefs.keys
      unused_keys.each{ |k| urihash.delete(k) }
      expect(docdefs).to eq(urihash)
    end
  end

  describe '#map' do
    context 'anthro profile' do
      context 'collectionobject rectype' do
        let(:testdoc) { get_xml_fixture('anthro/collectionobject_2.xml') }
        let(:resdoc) { remove_namespaces(@dm.doc) }
        let!(:xpaths) { test_xpaths(testdoc) } 

        it 'maps as expected' do
          xpaths.each do |xpath|
            is_date = xpath['Date'] ? true : false
            if is_date
              puts "#{xpath} - skipped"
              next
            else
              puts xpath
            end
            testnode = standardize_value(testdoc.xpath(xpath).text)
            resnode = standardize_value(resdoc.xpath(xpath).text)
            expect(resnode).to eq(testnode)
          end
        end
      end
    end
  end
end
