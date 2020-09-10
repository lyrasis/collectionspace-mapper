# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    @config = Mapper::DEFAULT_CONFIG
  end
  context 'lhmc profile' do
    before(:all) do
      @client = lhmc_client
      @cache = lhmc_cache
      populate_lhmc(@cache)
    end
    context 'person record' do
      before(:all) do
        @recmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/lhmc/lhmc_3_1_0-person.json')
        @handler = DataHandler.new(record_mapper: @recmapper, cache: @cache, client: @client, config: @config)
        @prepper = DataPrepper.new({'termDisplayName' => 'Xanadu', 'placeNote' => 'note'}, @handler)
        @datamapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
        @mapped_doc = remove_namespaces(@datamapper.response.doc)
      end

      describe '#add_short_id' do
        before(:all) do
          @short_id_nodeset = @mapped_doc.xpath('//shortIdentifier')
        end
        it 'adds one shortIdentifier element' do
          expect(@short_id_nodeset.length).to eq(1)
        end
        it 'adds shortIdentifier element to persons_common namespace group' do
          node = @short_id_nodeset.first
          expect(node.parent.name).to eq('persons_common')
        end
        it 'value of shortIdentifier is as expected' do
          node = @short_id_nodeset.first
          expect(node.text).to eq('Xanadu2760257775')
        end
      end

      describe '#set_response_identifier' do
        before(:all){ @response = @datamapper.response }
        it 'adds record identifier to response' do
          expect(@response.identifier).to eq('Xanadu2760257775')
        end
      end
    end
    end

    context 'botgarden profile' do
    before(:all) do
      @client = botgarden_client
      @cache = botgarden_cache
      populate_botgarden(@cache)
    end
    context 'loanout record' do
      before(:all) do
        @recmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_1_1_0-loanout.json')
        @handler = DataHandler.new(record_mapper: @recmapper, cache: @cache, client: @client, config: @config)
        @prepper = DataPrepper.new({'loanOutNumber' => '123', 'sterile' => 'n'}, @handler)
        @datamapper = DataMapper.new(@prepper.prep, @handler, @prepper.xphash)
      end

      describe '#set_response_identifier' do
        before(:all){ @response = @datamapper.response }
        it 'adds record identifier to response' do
          expect(@response.identifier).to eq('123')
        end
      end
    end
    end

    context 'anthro profile' do
      before(:all) do
        @client = anthro_client
        @cache = anthro_cache
        populate_anthro(@cache)
      end
      context 'place record' do
        before(:all) do
          @recmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-place.json')
          @handler = DataHandler.new(record_mapper: @recmapper, cache: @cache, client: @client, config: @config)
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
        config = Mapper::DEFAULT_CONFIG.merge({
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
        })

        @recmapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_0/anthro/anthro_4_0_0-collectionobject.json')
        @handler = DataHandler.new(record_mapper: @recmapper, cache: @cache, client: @client, config: config)
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

    describe '#add_namespaces' do
      it 'adds botgarden propagation namespace' do
        client = botgarden_client
        cache = botgarden_cache
        populate_botgarden(cache)
        config = {
          delimiter: ';',
          subgroup_delimiter: '^^',
        }
        prop_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_1_1_0-propagation.json')
        prop_handler = DataHandler.new(record_mapper: prop_mapper, cache: cache, client: client, config: config)
        datahash = get_datahash(path: 'spec/fixtures/files/datahashes/botgarden/propagation1.json')
        prepper = DataPrepper.new(datahash, prop_handler)
        mapper = DataMapper.new(prepper.prep, prop_handler, prepper.xphash)
      end
    end
end
