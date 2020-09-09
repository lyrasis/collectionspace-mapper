# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataHandler do
  context 'anthro' do
    before(:all) do
      @client = anthro_client
      @cache = anthro_cache
    end
    
    context 'place record, with no config parameter' do
      before(:all) do
        @place_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-place.json')
        @place_handler = DataHandler.new(record_mapper: @place_mapper, client: @client, cache: @cache)
      end

      describe '#is_authority' do
        it 'sets is_authority to true' do
          expect(@place_handler.is_authority).to be true
        end
        it 'adds a mapping for shortIdentifier' do
          result = @place_handler.mapper[:mappings].select{ |m| m[:fieldname] == 'shortIdentifier' }
          expect(result.length).to eq(1)
        end
        it 'adds a xphash entry for shortIdentifier' do
          result = @place_handler.mapper[:xpath]['places_common'][:mappings].select{ |m| m[:fieldname] == 'shortIdentifier' }
          expect(result.length).to eq(1)
        end
        it 'uses default config' do
          expect(@place_handler.config).to eq(Mapper::DEFAULT_CONFIG)
        end
      end
    end

    context 'collectionobject record' do
      before(:all) do
        config = Mapper::DEFAULT_CONFIG.merge({
          transforms: {
            'Collection' => {
              special: %w[downcase_value],
              replacements: [
                { find: ' ', replace: '-', type: :plain }
              ]
            }
          },
          default_values: {
            'publishTo' => 'DPLA;Omeka',
            'collection' => 'library-collection'
          }
        })

        @mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_0/anthro/anthro_4_0_0-collectionobject.json')
        @handler = DataHandler.new(record_mapper: @mapper, client: anthro_client, cache: anthro_cache, config: config)
      end

      describe '#is_authority' do
        it 'sets is_authority to false' do
          expect(@handler.is_authority).to be false
        end
      end

      describe '#process' do
        context 'when data hash is valid' do
          before(:all) do
            data = { 'objectNumber' => '123' }
            @result = @handler.process(data)
          end
        end
      end
      
      describe '#validate' do
        it 'returns Mapper::Response object' do
          data = { 'objectNumber' => '123' }
          result = @handler.validate(data)
          expect(result).to be_a(Mapper::Response)
        end
      end
      
      describe '#map' do
        before(:all) do
          data = { 'objectNumber' => '123' }
          prepper = DataPrepper.new(data, @handler)
          prepresponse = @handler.prep(data)
          @result = @handler.map(prepresponse, prepper.xphash)
        end
        
        it 'returns Mapper::Response object' do
          expect(@result).to be_a(Mapper::Response)
        end

        it 'the Mapper::Response object doc attribute is a Nokogiri XML Document' do
          expect(@result.doc).to be_a(Nokogiri::XML::Document)
        end
        
      end
      
      describe '#merge_config_transforms' do
        context 'collection data field' do
          it 'merges data field specific transforms' do
            fieldmap = @handler.mapper[:mappings].select{ |m| m[:fieldname] == 'collection' }.first
            xforms = {
              special: %w[downcase_value],
              replacements: [
                { find: ' ', replace: '-', type: :plain }
              ]
            }
            expect(fieldmap[:transforms]).to eq(xforms)
          end
        end
      end
      
      describe '#xpath_hash' do
        context 'xpath ending with commingledRemainsGroup' do
          let(:h) { @handler.mapper[:xpath]['collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup'] }
          it 'is_group = true' do
            expect(h[:is_group]).to be true
          end

          it 'is_subgroup = false' do
            expect(h[:is_subgroup]).to be false
          end

          it 'includes mortuaryTreatment as subgroup' do
            xpath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup/mortuaryTreatmentGroupList/mortuaryTreatmentGroup'
            expect(h[:children]).to eq([xpath])
          end

          it 'has mortuaryTreatment listed as only child' do
          end
        end

        context 'xpath ending with mortuaryTreatmentGroup' do
          let(:h) { @handler.mapper[:xpath]['collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup/mortuaryTreatmentGroupList/mortuaryTreatmentGroup'] }
          it 'is_group = true' do
            expect(h[:is_group]).to be true
          end

          it 'is_subgroup = true' do
            expect(h[:is_subgroup]).to be true
          end

          it 'parent is xpath ending with commingledRemainsGroup' do
            ppath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup'
            expect(h[:parent]).to eq(ppath)
          end
        end

        context 'xpath ending with collectionobjects_nagpra' do
          let(:h) { @handler.mapper[:xpath]['collectionobjects_nagpra'] }
          it 'has 5 children' do
            expect(h[:children].size).to eq(5)
          end
        end
      end
    end
    
    context 'bonsai_4_0_0 profile' do
      context 'conservation record type' do
        before(:all) do
          config = Mapper::DEFAULT_CONFIG
          @mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_0/bonsai/bonsai_4_0_0-conservation.json')
          @handler = DataHandler.new(record_mapper: @mapper, cache: bonsai_cache, client: bonsai_client, config: config)
        end
        context 'xpath ending with fertilizersToBeUsed' do
          it 'is a repeating group' do
            h = @handler.mapper[:xpath]
            res = h['conservation_livingplant/fertilizationGroupList/fertilizationGroup/fertilizersToBeUsed'][:is_group]
            expect(res).to be true
          end
        end
        context 'xpath ending with conservators' do
          it 'is a repeating group' do
            h = @handler.mapper[:xpath]
            res = h['conservation_common/conservators'][:is_group]
            expect(res).to be false
          end
        end
      end
    end
  end
end
