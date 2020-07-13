# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataMapper do
  before(:all) do
    config = {
      delimiter: ';',
      subgroup_delimiter: '^^',
      transforms: {
        'collection' => {
          special: %w[downcase_value],
          replacements: [
            { find: ' ', replace: '-', type: :plain }
          ]
        }
      },
      default_values: {
        'publishTo' => 'DPLA;Omeka',
        'collection' => 'library-collection'
      },
      force_defaults: false
    }

    @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/anthro_4_0_0-collectionobject.json')
    @dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, config: config)
    @dm = DataMapper.new(anthro_co_1, @dh, @dh.blankdoc)
  end
  
  describe '#map' do
    it 'returns XML doc' do
      res = @dm.map('collectionobjects_common')
      expect(res).to be_a(Nokogiri::XML::Document)
    end
  end
end
