# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::SubgroupColumnValue do
  let(:mapperpath) { 'spec/fixtures/files/mappers/release_6_1/core/core_6-1-0_collectionobject.json' }
  let(:config) { {delimiter: '|', subgroup_delimiter: '^^'} } 
  let(:recmapper) { CS::Mapper::RecordMapper.new(mapper: get_json_record_mapper(mapperpath),
                                                 batchconfig: config) }
  let(:mapping) { recmapper.mappings.lookup(colname) }
  let(:colval) { described_class.new(column: colname,
                                     value: colvalue,
                                     recmapper: recmapper,
                                     mapping: mapping) }

  describe '#split' do
    let(:colname) { 'titleTranslation' }
    let(:colvalue) { 'a|b^^c' }
    it 'returns value(s) as Hash where group occurrences are the keys' do
      expected = { 1=> ['a'],
                  2=> ['b', 'c'] }
      expect(colval.split).to eq(expected)
    end
  end
end

