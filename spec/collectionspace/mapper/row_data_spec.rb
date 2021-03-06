# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::RowData do
  let(:recmapper) { core_object_mapper}
  let(:data_hash) { {
    'objectNumber'=>'123',
    'comment'=>'blah',
    'title'=>'The title',
    'titleTranslation'=>'La title'
  } }

  let(:row) { CollectionSpace::Mapper::RowData.new(data_hash, recmapper) }

  describe '#columns' do
    it 'returns Array' do
      res = row.columns
      expect(row.columns).to be_a(Array)
    end
    it 'of ColumnValues' do
      expect(row.columns.any?{ |col| !col.kind_of?(CS::Mapper::ColumnValue)}).to be false
    end
    it '2 elements long' do
      expect(row.columns.length).to eq(4)
    end
  end
end
