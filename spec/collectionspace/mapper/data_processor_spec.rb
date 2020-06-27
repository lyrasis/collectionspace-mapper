# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataProcessor do
  before(:all) do
    @rm_anthro_co = CCU::RecordMapper::RecordMapping.new(profile: 'anthro_4_0_0', rectype: 'collectionobject').hash
    @dp = DataProcessor.new(record_mapper: @rm_anthro_co, cache: anthro_cache)
  end

  describe '#recmapper' do
    it 'returns RecordMapper hash' do
      expect(@dp.recmapper).to be_a(Hash)
    end
  end

  describe '#process' do
    context 'when required field not present in data' do
      let(:data) { {
        'dataHashID' => '1'
      } }
      let(:res) { @dp.process(data) }
      it 'returns hash with at least one error value' do
        expect(res[:errors].size).to be > 0
      end
      it 'returns hash with nil :doc' do
        expect(res[:doc]).to be_nil
      end
    end
  end
end
