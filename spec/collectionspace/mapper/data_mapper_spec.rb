# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  context 'lhmc profile' do
    before(:all) do
      @cache = lhmc_cache
      populate_lhmc(@cache)
    end
    context 'person record' do
      before(:all) do
        config = {
          delimiter: ';',
          subgroup_delimiter: '^^',
        }

        @recmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/lhmc/lhmc_3_1_0-person.json')
        @handler = DataHandler.new(record_mapper: @recmapper, cache: @cache, client: lhmc_client, config: config)
        @prepper = DataPrepper.new({'termDisplayName' => 'Xanadu', 'placeNote' => 'note'}, @handler)
        @datamapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
      end

      describe '#add_short_id' do
        it 'adds shortIdentifier' do
          
        end
      end
    end
    end

    context 'anthro profile' do
      before(:all) do
        @cache = anthro_cache
        populate_anthro(@cache)
      end
      context 'place record' do
        before(:all) do
          config = {
            delimiter: ';',
            subgroup_delimiter: '^^',
          }

          @recmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-place.json')
          @handler = DataHandler.new(record_mapper: @recmapper, cache: @cache, client: anthro_client, config: config)
          @prepper = DataPrepper.new({'termDisplayName' => 'Xanadu'}, @handler)
          @datamapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
        end

        describe '#add_short_id' do
          it 'adds shortIdentifier' do
            
          end
        end
      end

    context 'collectionobject record' do
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

        @recmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_0/anthro/anthro_4_0_0-collectionobject.json')
        @handler = DataHandler.new(record_mapper: @recmapper, cache: @cache, client: anthro_client, config: config)
        @prepper = DataPrepper.new(anthro_co_1, @handler)
        @datamapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
      end

      describe '#doc' do
        it 'returns XML doc' do
          res = @datamapper.doc
          expect(res).to be_a(Nokogiri::XML::Document)
        end
      end

      describe '#response' do
        it 'returns Mapper::Response object' do
          res = @datamapper.response
          expect(res).to be_a(Mapper::Response)
        end
        it 'Mapper::Response.doc is XML document' do
          res = @datamapper.response.doc
          expect(res).to be_a(Nokogiri::XML::Document)
        end
      end
      
      describe '#add_namespaces' do
        it 'adds namespace definitions' do
          urihash = @datamapper.handler.mapper[:config][:ns_uri].clone
          urihash.transform_keys!{ |k| "ns2:#{k}" }
          docdefs = {}
          @datamapper.doc.xpath('/*/*').each do |ns|
            docdefs[ns.name] = ns.namespace_definitions.select{ |d| d.prefix == 'ns2' }.first.href
          end
          unused_keys = urihash.keys - docdefs.keys
          unused_keys.each{ |k| urihash.delete(k) }
          expect(docdefs).to eq(urihash)
        end
      end
    end
  end
end
