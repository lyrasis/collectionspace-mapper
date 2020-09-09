# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Identifiers do
  describe '#short_identifier' do
    it 'generates identifiers' do
      names = {
        'Jurgen Klopp!' => 'JurgenKlopp1289035554',
        'Achillea millefolium' => 'Achilleamillefolium1482849582'
      }

      names.each do |name, id|
        expect(Identifiers.short_identifier(name)).to eq(id)
      end
    end
  end
end
