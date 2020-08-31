# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataValidator do
  before(:all) do
    @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_0/anthro/anthro_4_0_0-collectionobject.json')
    @dv = DataValidator.new(@rm_anthro_co, anthro_cache)
  end
  
  it 'gets downcased list of required fields' do
    expect(@dv.required_fields).to eq(['objectnumber'])
  end

  describe '#validate' do
    it 'returns a Mapper::Response' do
      data = { 'objectNumber' => '123' }
      expect(@dv.validate(data)).to be_a(Mapper::Response)
    end
      
      context 'when required field present' do
        context 'and required field populated' do
          it 'no required field error returned' do
            data = { 'objectNumber' => '123' }
            v = @dv.validate(data)
            err = v.errors.select{ |errhash| errhash[:type].start_with?('required field') }
            expect(err.size).to eq(0)
          end
        end

        context 'and required field present but empty' do
          it 'required field error returned with message "required field empty"' do
            data = { 'objectNumber' => '' }
            v = @dv.validate(data)
            err = v.errors.select{ |errhash| errhash[:type] == 'required field empty' }
            expect(err.size).to eq(1)
          end
        end
      end

      context 'when required field not present in data' do
        it 'required field error returned with message "required field missing"' do
          data = { 'randomField' => 'random value' }
          v = @dv.validate(data)
          err = v.errors.select{ |errhash| errhash[:type] == 'required field missing' }
          expect(err.size).to eq(1)
        end
      end
    end
  end
