# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataValidator do
  before(:all) do
    @anthro_object_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/anthro/anthro_4_1_0-collectionobject.json')
    @anthro_dv = DataValidator.new(RecordMapper.convert(@anthro_object_mapper), anthro_cache)
    @botgarden_loanout_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/botgarden/botgarden_1_1_0-loanout.json')
    @botgarden_dv = DataValidator.new(RecordMapper.convert(@botgarden_loanout_mapper), botgarden_cache)
  end
  
  it 'gets downcased list of required fields' do
    expect(@anthro_dv.required_fields).to eq(['objectnumber'])
  end

  describe '#validate' do
    it 'returns a CollectionSpace::Mapper::Response' do
      data = { 'objectNumber' => '123' }
      expect(@anthro_dv.validate(data)).to be_a(CollectionSpace::Mapper::Response)
    end

    context 'when recordtype has required field(s)' do
      context 'and when required field present' do
        context 'and required field populated' do
          it 'no required field error returned' do
            data = { 'objectNumber' => '123' }
            v = @anthro_dv.validate(data)
            err = v.errors.select{ |errhash| errhash[:type].start_with?('required field') }
            expect(err.size).to eq(0)
          end
        end

        context 'and required field present but empty' do
          it 'required field error returned with message "required field empty"' do
            data = { 'objectNumber' => '' }
            v = @anthro_dv.validate(data)
            err = v.errors.select{ |errhash| errhash[:type] == 'required field empty' }
            expect(err.size).to eq(1)
          end
        end
      end

      context 'when required field not present in data' do
        it 'required field error returned with message "required field missing"' do
          data = { 'randomField' => 'random value' }
          v = @anthro_dv.validate(data)
          err = v.errors.select{ |errhash| errhash[:type] == 'required field missing' }
          expect(err.size).to eq(1)
        end
      end
    end

    context 'when recordtype has no required field(s)' do
      context 'and when record id field present' do
        context 'and record id field populated' do
          it 'no record id field error returned' do
            data = { 'loanOutNumber' => '123' }
            v = @botgarden_dv.validate(data)
            err = v.errors.select{ |errhash| errhash[:type].start_with?('record id field') }
            expect(err.size).to eq(0)
          end
        end

        context 'and record id field present but empty' do
          it 'record id field error returned with message "record id field empty"' do
            data = { 'loanOutNumber' => '' }
            v = @botgarden_dv.validate(data)
            err = v.errors.select{ |errhash| errhash[:type] == 'record id field empty' }
            expect(err.size).to eq(1)
          end
        end
      end

      context 'when record id field not present in data' do
        it 'record id field error returned with message "record id field missing"' do
          data = { 'randomField' => 'random value' }
          v = @botgarden_dv.validate(data)
          err = v.errors.select{ |errhash| errhash[:type] == 'record id field missing' }
          expect(err.size).to eq(1)
        end
      end
    end
  end
end
