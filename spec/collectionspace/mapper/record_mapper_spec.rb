# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::RecordMapper do
  before(:all) do
    mapper_json = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_2-collectionobject.json')
    @mapper = CollectionSpace::Mapper::RecordMapper.new(mapper_json)
  end

  it 'has expected instance variables' do
    expected = [:@xpath, :@config, :@docstructure, :@mappings].sort
    expect(@mapper.instance_variables.sort).to eq(expected)
  end


end