# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::XpathMapper do
  let(:rm_anthro_co) { CCU::RecordMapper::RecordMapping.new(profile: 'anthro_4_0_0', rectype: 'collectionobject').hash }
  let(:dm) { DataMapper.new(record_mapper: rm_anthro_co, cache: anthro_cache) }
  let(:xm) { XpathMapper.new(anthro_co_1, dm, dm.blankdoc) }

  describe '#map' do
    it 'returns XML doc' do
      res = xm.map('collectionobjects_common')
      puts res
      expect(res).to be_a(Nokogiri::XML::Document)
    end
  end
end
