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
    @dm = DataMapper.new(anthro_co_1, @dh)
  end

  describe '#merge_default_values' do
    context 'when no default_values specified in config' do
      it 'does not fall over' do
        config = {
          delimiter: ';',
          subgroup_delimiter: '^^',
          force_defaults: false
        }
        dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, client: anthro_client, config: config)
        dm = DataMapper.new(anthro_co_1, @dh)
        anthro_co_1_nsfree = remove_namespaces(dm.doc)
        anthro_co_1_nsfree.xpath('/*/*').each{ |n| n.name = n.name.sub('ns2:', '') }

        path = '/document/collectionobjects_common/collection'
        res = anthro_co_1_nsfree.xpath(path).text
        ex = 'permanent-collection'
        expect(res).to eq(ex)
      end
    end
    context 'when default_values for a field is specified in config' do
      before(:all) do
        @anthro_co_1_nsfree = remove_namespaces(@dm.doc)
      end
      context 'and no value is given for that field in the incoming data' do
        it 'maps the default values' do
          path = '/document/collectionobjects_common/publishToList/publishTo'
          res = @anthro_co_1_nsfree.xpath(path).text
          ex = "urn:cspace:anthro.collectionspace.org:vocabularies:name(publishto):item:name(dpla)'DPLA'urn:cspace:anthro.collectionspace.org:vocabularies:name(publishto):item:name(omeka)'Omeka'"
          expect(res).to eq(ex)
        end
      end
      context 'and value is given for that field in the incoming data' do
        context 'and :force_defaults = false' do
          it 'maps the value in the incoming data' do
            path = '/document/collectionobjects_common/collection'
            res = @anthro_co_1_nsfree.xpath(path).text
            ex = 'permanent-collection'
            expect(res).to eq(ex)
          end
        end
        context 'and :force_defaults = true' do
          it 'maps the default value, overwriting value in the incoming data' do
            config = {
              delimiter: ';',
              subgroup_delimiter: '^^',
              default_values: {
                'collection' => 'library-collection'
              },
              force_defaults: true
            }
            dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, client: anthro_client, config: config)
            dm = DataMapper.new(anthro_co_1, dh)
            anthro_co_1_nsfree = remove_namespaces(dm.doc)

            path = '/document/collectionobjects_common/collection'
            res = anthro_co_1_nsfree.xpath(path).text
            ex = 'library-collection'
            expect(res).to eq(ex)
          end
        end
      end
    end
  end
  
  describe '#doc' do
    it 'returns XML doc' do
      res = @dm.doc
      expect(res).to be_a(Nokogiri::XML::Document)
    end
  end

  describe '#map_result' do
    it 'does' do
      puts @dm.result.missing_terms.inspect
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
