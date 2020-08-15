# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataHandler do
  before(:all) do
    config = {
      delimiter: ';',
      subgroup_delimiter: '^^',
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
      },
      force_defaults: false
    }

    @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/anthro_4_0_0-collectionobject.json')
    @dh = DataHandler.new(record_mapper: @rm_anthro_co, client: anthro_client, cache: anthro_cache, config: config)
    #  @anthro_co_1_doc = @dh.map(anthro_co_1)

    @rm_bonsai_cons = get_json_record_mapper(path: 'spec/fixtures/files/mappers/bonsai_4_0_0-conservation.json')
    @dm_bonsai_cons = DataHandler.new(record_mapper: @rm_bonsai_cons, cache: bonsai_cache, client: bonsai_client, config: config)
  end

  describe '#process' do
    context 'when data hash is valid' do
    before(:all) do
      data = { 'objectNumber' => '123' }
      @result = @dh.process(data)
    end
    end
  end
  
  describe '#validate' do
    it 'returns Mapper::Response object' do
      data = { 'objectNumber' => '123' }
      result = @dh.validate(data)
      expect(result).to be_a(Mapper::Response)
    end
  end
  
  describe '#map' do
    before(:all) do
      data = { 'objectNumber' => '123' }
      prepper = DataPrepper.new(data, @dh)
      prepresponse = @dh.prep(data)
      @result = @dh.map(prepresponse, prepper.xphash)
    end
    
    it 'returns Mapper::Response object' do
      expect(@result).to be_a(Mapper::Response)
    end

    it 'the Mapper::Response object doc attribute is a Nokogiri XML Document' do
      expect(@result.doc).to be_a(Nokogiri::XML::Document)
    end
    
  end
  
  describe '#merge_config_transforms' do
    context 'anthro_4_0_0 profile' do
      context 'collectionobject record type' do
        context 'collection data field' do
          it 'merges data field specific transforms' do
            fieldmap = @dh.mapper[:mappings].select{ |m| m[:fieldname] == 'collection' }.first
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
    context 'anthro_4_0_0 profile' do
      context 'collectionobject record type' do
        context 'xpath ending with commingledRemainsGroup' do
          let(:h) { @dh.mapper[:xpath]['collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup'] }
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
          let(:h) { @dh.mapper[:xpath]['collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup/mortuaryTreatmentGroupList/mortuaryTreatmentGroup'] }
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
          let(:h) { @dh.mapper[:xpath]['collectionobjects_nagpra'] }
          it 'has 5 children' do
            expect(h[:children].size).to eq(5)
          end
        end
      end
    end
    
    context 'bonsai_4_0_0 profile' do
      context 'conservation record type' do
        context 'xpath ending with fertilizersToBeUsed' do
          it 'is a repeating group' do
            h = @dm_bonsai_cons.mapper[:xpath]
            res = h['conservation_livingplant/fertilizationGroupList/fertilizationGroup/fertilizersToBeUsed'][:is_group]
            expect(res).to be true
          end
        end
        context 'xpath ending with conservators' do
          it 'is a repeating group' do
            h = @dm_bonsai_cons.mapper[:xpath]
            res = h['conservation_common/conservators'][:is_group]
            expect(res).to be false
          end
        end
      end
    end
  end
end
