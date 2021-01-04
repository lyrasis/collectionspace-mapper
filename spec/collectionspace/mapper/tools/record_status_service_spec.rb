# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::RecordStatusService do
  before(:all) do
    @core_client = core_client
  end

  describe '#lookup' do
    context 'when mapper is for an authority' do
      before(:all) do
        @core_person_mapper = CollectionSpace::Mapper::Tools::RecordMapper.convert(get_json_record_mapper(
          path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-person-local.json'
        ))
        @service = CollectionSpace::Mapper::Tools::RecordStatusService.new(@core_client, @core_person_mapper)
      end

      context 'and one result is found' do
        before(:all) do
          @report = @service.lookup('John Doe')
        end
        it 'status = :existing' do
          expect(@report[:status]).to eq(:existing)
        end
        it 'csid = 775740c2-2484-4194-93f0' do
          expect(@report[:csid]).to eq('775740c2-2484-4194-93f0')
        end
        it 'uri = /personauthorities/0f6cddfa-32ce-4c25-9b2f/items/775740c2-2484-4194-93f0' do
          expect(@report[:uri]).to eq('/personauthorities/0f6cddfa-32ce-4c25-9b2f/items/775740c2-2484-4194-93f0')
        end
        it 'refname = the correct refname' do
          refname = "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnDoe1416422840)'John Doe'"
          expect(@report[:refname]).to eq(refname)
        end
      end

      context 'and no result is found' do
        it 'status = :new' do
          status = @service.lookup('Chickweed Guineafowl')[:status]
          expect(status).to eq(:new)
        end
      end

      context 'and multiple results found' do
        # if this test fails, verify there are two person/local authority records for 'Inkpot Guineafowl'
        #   in core.dev
        # you may need to re-create them if they have been removed
        it 'raises error because we cannot know what to do with imported record' do
          expect{ @service.lookup('Inkpot Guineafowl') }.to raise_error(CollectionSpace::Mapper::MultipleCsRecordsFoundError)
        end
      end
    end

    context 'when mapper is for an object' do
      before(:all) do
        @core_co_mapper = CollectionSpace::Mapper::Tools::RecordMapper.convert(get_json_record_mapper(
          path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-collectionobject.json'
        ))
        @service = CollectionSpace::Mapper::Tools::RecordStatusService.new(@core_client, @core_co_mapper)
      end
      it 'works the same' do
        res = @service.lookup('2000.1')
        expect(res[:status]).to eq(:existing)
      end
    end

    context 'when mapper is for a procedure' do
      before(:all) do
        @core_acq_mapper = CollectionSpace::Mapper::Tools::RecordMapper.convert(get_json_record_mapper(
          path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-acquisition.json'
        ))
        @service = CollectionSpace::Mapper::Tools::RecordStatusService.new(@core_client, @core_acq_mapper)
      end
      it 'works the same' do
        res = @service.lookup('2000.001')
        expect(res[:status]).to eq(:existing)
      end
    end
  end
end
