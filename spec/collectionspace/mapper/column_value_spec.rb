# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ColumnValue do
  let(:recmapper) { core_object_mapper}

  let(:colval) { described_class.new('measuredByOrganization', 'Acme' , recmapper) }

  describe '#mapping' do
    it 'returns the ColumnMapping object for this column' do
      expect(colval.mapping.fieldname).to eq('measuredBy')
    end
  end
end
