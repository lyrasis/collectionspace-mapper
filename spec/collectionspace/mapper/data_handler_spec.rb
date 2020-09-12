# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataHandler do
  before(:all) do
    @anthro_client = anthro_client
    @anthro_cache = anthro_cache
    @anthro_object_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-collectionobject.json')
    @anthro_object_handler = DataHandler.new(@anthro_object_mapper, @anthro_client, @anthro_cache)
    @anthro_place_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-place.json')
    @anthro_place_handler = DataHandler.new(@anthro_place_mapper, @anthro_client, @anthro_cache)

    @bonsai_client = bonsai_client
    @bonsai_cache = bonsai_cache
    @bonsai_conservation_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/bonsai/bonsai_4_1_0-conservation.json')
    @bonsai_conservation_handler = DataHandler.new(@bonsai_conservation_mapper, @bonsai_client, @bonsai_cache)
end

  context 'when no config is passed at initialization' do
    it 'uses default config' do
      expect(@anthro_place_handler.config).to eq(Mapper::DEFAULT_CONFIG)
    end
  end
  
  describe '#is_authority' do
    context 'anthro profile' do
      context 'place record' do
        it 'sets is_authority to true' do
          expect(@anthro_place_handler.is_authority).to be true
        end
        it 'adds a mapping for shortIdentifier' do
          result = @anthro_place_handler.mapper[:mappings].select{ |m| m[:fieldname] == 'shortIdentifier' }
          expect(result.length).to eq(1)
        end
        it 'adds a xphash entry for shortIdentifier' do
          result = @anthro_place_handler.mapper[:xpath]['places_common'][:mappings].select{ |m| m[:fieldname] == 'shortIdentifier' }
          expect(result.length).to eq(1)
        end
      end
      context 'collectionobject record' do
        it 'is_authority = false' do
          expect(@anthro_object_handler.is_authority).to be false
        end
      end
    end
  end

  describe '#merge_config_transforms' do
    context 'anthro profile' do
      context 'collectionobject record' do
        before(:all) do
          @config = Mapper::DEFAULT_CONFIG.merge({
            transforms: {
              'Collection' => {
                special: %w[downcase_value],
                replacements: [
                  { find: ' ', replace: '-', type: :plain }
                ]
              }
            }
          })
        end
        context 'collection data field' do
          it 'merges data field specific transforms' do
            handler = DataHandler.new(@anthro_object_mapper, @anthro_client, @anthro_cache, @config)
            fieldmap = handler.mapper[:mappings].select{ |m| m[:fieldname] == 'collection' }.first
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
    end
  end

  describe '#xpath_hash' do
    context 'anthro profile' do
      context 'collectionobject record' do
        context 'xpath ending with commingledRemainsGroup' do
          before(:all) do
            xpath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup'
            @h = @anthro_object_handler.mapper[:xpath][xpath]
          end
          it 'is_group = true' do
            expect(@h[:is_group]).to be true
          end

          it 'is_subgroup = false' do
            expect(@h[:is_subgroup]).to be false
          end

          it 'includes mortuaryTreatment as subgroup' do
            xpath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup/mortuaryTreatmentGroupList/mortuaryTreatmentGroup'
            expect(@h[:children]).to eq([xpath])
          end

          xit 'has mortuaryTreatment listed as only child' do
          end
        end

        context 'xpath ending with mortuaryTreatmentGroup' do
          before(:all) do
            xpath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup/mortuaryTreatmentGroupList/mortuaryTreatmentGroup'
            @h = @anthro_object_handler.mapper[:xpath][xpath]
          end
          it 'is_group = true' do
            expect(@h[:is_group]).to be true
          end

          it 'is_subgroup = true' do
            expect(@h[:is_subgroup]).to be true
          end

          it 'parent is xpath ending with commingledRemainsGroup' do
            ppath = 'collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup'
            expect(@h[:parent]).to eq(ppath)
          end
        end

        context 'xpath ending with collectionobjects_nagpra' do
          before(:all) do
            @h = @anthro_object_handler.mapper[:xpath]['collectionobjects_nagpra']
          end
          it 'has 5 children' do
            expect(@h[:children].size).to eq(5)
          end
        end
      end
    end
context 'bonsai profile' do
  context 'conservation record type' do
    context 'xpath ending with fertilizersToBeUsed' do
      it 'is a repeating group' do
        h = @bonsai_conservation_handler.mapper[:xpath]
        res = h['conservation_livingplant/fertilizationGroupList/fertilizationGroup/fertilizersToBeUsed'][:is_group]
        expect(res).to be true
      end
    end
    context 'xpath ending with conservators' do
      it 'is a repeating group' do
        h = @bonsai_conservation_handler.mapper[:xpath]
        res = h['conservation_common/conservators'][:is_group]
        expect(res).to be false
      end
    end
  end
end
  end

  describe '#validate' do
    it 'returns Mapper::Response object' do
      data = { 'objectNumber' => '123' }
      result = @anthro_object_handler.validate(data)
      expect(result).to be_a(Mapper::Response)
    end
  end

  describe '#check_fields' do
    before(:all) do
      @data = {
        'conservationNumber' => '123',
        'status' => 'good',
        'conservator' => 'Someone'
      }
    end
    it 'returns expected hash' do
      expect = {
        known_fields: %w[conservationnumber status],
        unknown_fields: %w[conservator]
      }
    end
  end
  
  describe '#prep' do
    before(:all) do
      @data = { 'objectNumber' => '123' }
    end
    it 'can be called with response from validation' do
      vresult = @anthro_object_handler.validate(@data)
      result = @anthro_object_handler.prep(vresult)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
    it 'can be called with just data' do
      result = @anthro_object_handler.prep(@data)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
    context 'when response_mode = normal' do
      it 'returned response to include detailed data transformation info needed for mapping' do
        result = @anthro_object_handler.prep(@data)
        expect(result.transformed_data).not_to be_empty
      end
    end
    context 'when response_mode = verbose' do
      it 'returned response includes detailed data transformation info' do
        config = Mapper::DEFAULT_CONFIG.merge({ response_mode: 'verbose' })
        handler = DataHandler.new(@anthro_object_mapper, @anthro_client, @anthro_cache, config)
        result = handler.prep(@data)
        expect(result.transformed_data).not_to be_empty
      end
    end
  end

  describe '#process' do
    before(:all) do
      @data = { 'objectNumber' => '123' }
    end
    it 'can be called with response from validation' do
      vresult = @anthro_object_handler.validate(@data)
      result = @anthro_object_handler.process(vresult)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
    it 'can be called with just data' do
      result = @anthro_object_handler.process(@data)
      expect(result).to be_a(CollectionSpace::Mapper::Response)
    end
    context 'when response_mode = normal' do
      it 'returned response omits detailed data transformation info' do
        result = @anthro_object_handler.process(@data)
        expect(result.transformed_data).to be_empty
      end
    end
    context 'when response_mode = verbose' do
      it 'returned response includes detailed data transformation info' do
        config = Mapper::DEFAULT_CONFIG.merge({ response_mode: 'verbose' })
        handler = DataHandler.new(@anthro_object_mapper, @anthro_client, @anthro_cache, config)
        result = handler.process(@data)
        expect(result.transformed_data).not_to be_empty
      end
    end
  end
  
  describe '#map' do
    before(:all) do
      @data = { 'objectNumber' => '123' }
      prepper = DataPrepper.new(@data, @anthro_object_handler)
      prep_response = @anthro_object_handler.prep(@data)
      @result = @anthro_object_handler.map(prep_response, prepper.xphash)
    end
    
    it 'returns Mapper::Response object' do
      expect(@result).to be_a(Mapper::Response)
    end

    it 'the Mapper::Response object doc attribute is a Nokogiri XML Document' do
      expect(@result.doc).to be_a(Nokogiri::XML::Document)
    end
    context 'when response_mode = normal' do
      it 'returned response omits detailed data transformation info' do
        expect(@result.transformed_data).to be_empty
      end
    end
    context 'when response_mode = verbose' do
      it 'returned response includes detailed data transformation info' do
        config = Mapper::DEFAULT_CONFIG.merge({ response_mode: 'verbose' })
        handler = DataHandler.new(@anthro_object_mapper, @anthro_client, @anthro_cache, config)
        prepper = DataPrepper.new(@data, handler)
        result = handler.map(handler.prep(@data), prepper.xphash)
        expect(result.transformed_data).not_to be_empty
      end
    end
  end
end
