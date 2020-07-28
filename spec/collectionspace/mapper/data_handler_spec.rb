# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataHandler do
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
  @anthro_co_1_doc = @dh.map(anthro_co_1)

  @rm_bonsai_cons = get_json_record_mapper(path: 'spec/fixtures/files/mappers/bonsai_4_0_0-conservation.json')
  @dm_bonsai_cons = DataHandler.new(record_mapper: @rm_bonsai_cons, cache: bonsai_cache, client: bonsai_client, config: config)
  end

  describe '#validate' do
    context 'when required field(s) present and populated' do
      it 'returns empty array' do
        data = { 'objectNumber' => '123' }
        result = @dh.validate(data)
        expect(result).to eq([])
      end
    end
    context 'when required field(s) not present' do
      let(:data) { { 'nonrequiredField' => '123' } }
      let(:result) { @dh.validate(data) }
      it 'returns array' do
        expect(result).to be_a(Array)
      end
      it 'array contains one error' do
        expect(result.size).to eq(1)
      end
      it 'error has field "objectnumber"' do
        expect(result[0][:field]).to eq('objectnumber')
      end
      it 'error has type "required fields"' do
        expect(result[0][:type]).to eq('required fields')
      end
      it 'error has message "required field missing"' do
        expect(result[0][:message]).to eq('required field missing')
      end
    end
    context 'when required field(s) present but empty' do
      let(:data) { { 'objectNumber' => '' } }
      let(:result) { @dh.validate(data) }
      it 'returns array' do
        expect(result).to be_a(Array)
      end
      it 'array contains one error' do
        expect(result.size).to eq(1)
      end
      it 'error has field "objectnumber"' do
        expect(result[0][:field]).to eq('objectnumber')
      end
      it 'error has type "required fields"' do
        expect(result[0][:type]).to eq('required fields')
      end
      it 'error has message "required field is empty"' do
        expect(result[0][:message]).to eq('required field is empty')
      end
    end
  end
  
  describe '#map' do
    it 'returns Mapper::MapResult object' do
      expect(@anthro_co_1_doc).to be_a(CollectionSpace::Mapper::MapResult)
    end
  end
  
  describe '#merge_config_transforms' do
    context 'anthro_4_0_0 profile' do
      context 'collectionobject record type' do
        context 'collection data field' do
          it 'merges data field specific transforms from config.json' do
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
