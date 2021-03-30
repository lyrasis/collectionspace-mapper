# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ColumnMappings do
  let(:hash_mappings) { [
      {:fieldname=>"objectNumber",
       :transforms=>{},
       :source_type=>"na",
       :source_name=>nil,
       :namespace=>"collectionobjects_common",
       :xpath=>[],
       :data_type=>"string",
       :repeats=>"n",
       :in_repeating_group=>"n/a",
       :opt_list_values=>[],
       :datacolumn=>"objectNumber",
       :required=>"y"},
      {:fieldname=>"numberOfObjects",
       :transforms=>{},
       :source_type=>"na",
       :source_name=>nil,
       :namespace=>"collectionobjects_common",
       :xpath=>[],
       :data_type=>"integer",
       :repeats=>"n",
       :in_repeating_group=>"n/a",
       :opt_list_values=>[],
       :datacolumn=>"numberOfObjects",
       :required=>"n"},
      {:fieldname=>"numberValue",
       :transforms=>{},
       :source_type=>"na",
       :source_name=>nil,
       :namespace=>"collectionobjects_common",
       :xpath=>["otherNumberList", "otherNumber"],
       :data_type=>"string",
       :repeats=>"n",
       :in_repeating_group=>"y",
       :opt_list_values=>[],
       :datacolumn=>"numberValue",
       :required=>"n"},
      {:fieldname=>"numberType",
       :transforms=>{},
       :source_type=>"optionlist",
       :source_name=>"numberTypes",
       :namespace=>"collectionobjects_common",
       :xpath=>["otherNumberList", "otherNumber"],
       :data_type=>"string",
       :repeats=>"n",
       :in_repeating_group=>"y",
       :opt_list_values=>["lender", "obsolete", "previous", "serial", "unknown"],
       :datacolumn=>"numberType",
       :required=>"n"},
      {:datacolumn=>"otherRequired",
       :required=>"y"}
    ] }

  let(:mappings) { CollectionSpace::Mapper::ColumnMappings.new(hash_mappings) }

  let(:added_field) { {
    fieldname: 'shortIdentifier',
    namespace: 'persons_common',
    data_type: 'string',
    xpath: [],
    required: 'not in input data',
    repeats: 'n',
    in_repeating_group: 'n/a',
    datacolumn: 'shortIdentifier'
  } }



  describe '#known_columns' do
    it 'returns list of downcased datacolumns' do
      expected = %w[objectnumber numberofobjects numbervalue numbertype otherrequired].sort
      expect(mappings.known_columns.sort).to eq(expected)
    end
  end

  describe '#required_columns' do
    it 'returns column mappings for required fields' do
      expect(mappings.required_columns.map(&:datacolumn).sort.join(' ')).to eq('objectnumber otherrequired')
    end
  end

  describe '#<<' do
    it 'adds a mapping' do
      mappings << added_field
      expect(mappings.known_columns.include?('shortidentifier')).to be true
    end
  end

  describe '#lookup' do
    it 'returns ColumnMapping for column name' do
      result = mappings.lookup('numberType').fieldname
      expect(result).to eq('numberType')
    end
  end
end
