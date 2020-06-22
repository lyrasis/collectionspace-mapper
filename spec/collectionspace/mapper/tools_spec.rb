# frozen_string_literal: true

RSpec.describe CollectionSpace::Mapper::Tools do
  describe RecordMapperUntangler do
    let(:recordmapper) { RecordMapperUntangler.new(profile: 'anthro_4_0_0', rectype: 'collectionobject') }
    it 'returns RecordMapperUntangler object' do
      expect(recordmapper).to be_a(CollectionSpace::Mapper::Tools::RecordMapperUntangler)
    end

    describe '#to_h' do
      it 'returns the record mapper as a hash' do
        expect(recordmapper.to_h).to be_a(Hash)
      end
    end
  end

  describe RecordMapperJson do
    let(:recordmapper) { RecordMapperJson.new(file: 'spec/fixtures/files/anthro_4_0_0-collectionobject.json') }
    it 'returns RecordMapperJson object' do
      expect(recordmapper).to be_a(CollectionSpace::Mapper::Tools::RecordMapperJson)
    end
    describe '#to_h' do
      it 'returns the record mapper as a hash' do
        expect(recordmapper.to_h).to be_a(Hash)
      end
    end
  end
end
