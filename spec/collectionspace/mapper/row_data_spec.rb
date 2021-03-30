# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::RowData do
  let(:recmapper) { core_object_mapper}
  let(:data_hash) { {
    'objectNumber'=>'123',
    'numberOfObjects'=>'1'
  }
  }

  let(:row) { CollectionSpace::Mapper::RowData.new(data_hash, recmapper) }

  describe '#columns' do
    it 'returns Array' do
      expect(row.columns).to be_a(Array)
    end
    it 'of ColumnValues' do
      expect(row.columns.first).to be_a(CS::Mapper::ColumnValue)
    end
    it '2 elements long' do
      expect(row.columns.length).to eq(2)
    end
  end
end
