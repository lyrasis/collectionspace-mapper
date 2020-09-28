# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataQualityChecker do
    context 'when source_type = optionlist' do
      mapping = {
        fieldname: 'collection',
        datacolumn: 'collection',
        transforms: {},
        source_type: 'optionlist',
        opt_list_values: [
          'library-collection',
          'permanent-collection',
          'study-collection',
          'teaching-collection'
        ]
      }
      context 'and value is not in option list' do
        it 'returns warning' do
          data = ['Permanent Collection']
          res = CollectionSpace::Mapper::DataQualityChecker.new(mapping, data).warnings
          expect(res.size).to eq(1)
        end
      end
      context 'and value is in option list' do
        it 'does not return warning' do
          data = ['permanent-collection']
          res = CollectionSpace::Mapper::DataQualityChecker.new(mapping, data).warnings
          expect(res).to be_empty
        end
      end
    end
end
