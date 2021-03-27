# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ColumnMappings do
  before(:all) do
    hash_mappings = [
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
    ]
    @mappings = CollectionSpace::Mapper::ColumnMappings.new(hash_mappings)
  end

  describe '#known_columns' do
    it 'returns list of downcased datacolumns' do
      expected = %w[objectnumber numberofobjects numbervalue numbertype otherrequired].sort
      expect(@mappings.known_columns.sort).to eq(expected)
    end
  end

  describe '#required' do
    it 'returns column mappings for required fields' do
      expect(@mappings.required.map(&:datacolumn).sort.join(' ')).to eq('objectnumber otherrequired')
    end
  end

end
