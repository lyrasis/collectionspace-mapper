# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) { Mapper::CONFIG[:transforms] = {
    'collection' => {
      special: %i[downcase_value],
      replacements: [
        { find: ' ', replace: '-', type: :plain }
        ]
    }
  } }
  
  let(:rm_anthro_co) { CCU::RecordMapper::RecordMapping.new(profile: 'anthro_4_0_0', rectype: 'collectionobject').hash }
  let(:dm) { DataMapper.new(record_mapper: rm_anthro_co, cache: anthro_cache) }

  let(:rm_bonsai_cons) { CCU::RecordMapper::RecordMapping.new(profile: 'bonsai_4_0_0', rectype: 'conservation').hash }
  let(:dm_bonsai_cons) { DataMapper.new(record_mapper: rm_bonsai_cons, cache: bonsai_cache) }
  describe '#map' do
    it 'returns XML doc' do
      res = dm.map(anthro_co_1)
      expect(res).to be_a(Nokogiri::XML::Document)
    end
  end

  describe '#merge_config_transforms' do
    context 'anthro_4_0_0 profile' do
      context 'collectionobject record type' do
        context 'collection data field' do
          it 'merges data field specific transforms from config.json' do
            fieldmap = dm.mapper[:mappings].select{ |m| m[:fieldname] == 'collection' }.first
            pp(fieldmap)
            xforms = {
              special: %i[downcase_value],
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
  
  describe '#namespace_hash' do
    it 'returns expect hash of namespace URIs' do
      expected = {
        'xmlns:ns2' => 'http://collectionspace.org/services/collectionobject/domain/annotation',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
      }
      res = dm.namespace_hash('collectionobjects_annotation')
      expect(res).to eq(expected)
    end
  end

  describe '#xpath_hash' do
    context 'anthro_4_0_0 profile' do
      context 'collectionobject record type' do
        context 'xpath ending with commingledRemainsGroup' do
          let(:h) { dm.mapper[:xpath]['collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup'] }
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
          let(:h) { dm.mapper[:xpath]['collectionobjects_anthro/commingledRemainsGroupList/commingledRemainsGroup/mortuaryTreatmentGroupList/mortuaryTreatmentGroup'] }
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
          let(:h) { dm.mapper[:xpath]['collectionobjects_nagpra'] }
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
            h = dm_bonsai_cons.mapper[:xpath]
            res = h['conservation_livingplant/fertilizationGroupList/fertilizationGroup/fertilizersToBeUsed'][:is_group]
            expect(res).to be true
          end
        end
        context 'xpath ending with conservators' do
          it 'is a repeating group' do
            h = dm_bonsai_cons.mapper[:xpath]
            res = h['conservation_common/conservators'][:is_group]
            expect(res).to be false
          end
        end
      end
    end
  end
end
