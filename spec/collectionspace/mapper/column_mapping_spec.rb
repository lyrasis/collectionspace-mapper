# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ColumnMapping do

  # all mapping hash keys from Untangler
  #      :fieldname=>"numberValue",
  #      :transforms=>{},
  #      :source_type=>"na",
  #      :source_name=>nil,
  #      :namespace=>"collectionobjects_common",
  #      :xpath=>["otherNumberList", "otherNumber"],
  #      :data_type=>"string",
  #      :repeats=>"n",
  #      :in_repeating_group=>"y",
  #      :opt_list_values=>[],
  #      :datacolumn=>"numberValue",
  #      :required=>"n"

  describe '#fullpath' do
    before(:all) do
      hash_mapping = {
        :namespace=>"collectionobjects_common",
        :xpath=>["otherNumberList", "otherNumber"],
      }
      @mapping = described_class.new(hash_mapping)
    end
    it 'returns full xpath to target CollectionSpace field' do
      expected = 'collectionobjects_common/otherNumberList/otherNumber'
      expect(@mapping.fullpath).to eq(expected)
    end
  end

  describe '#required?' do
    context 'with required = y' do
      it 'returns true' do
        mapping = described_class.new({ :required=>"y" })
        expect(mapping.required?).to be true
      end
    end

    context 'with required = n' do
      it 'returns false' do
        mapping = described_class.new({ :required=>"n" })
        expect(mapping.required?).to be false
      end
    end
  end
end
