# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataQualityChecker do
  context 'when source_type = authority' do
    mapping = {
      fieldname: 'annotationAuthor',
      datacolumn: 'annotationAuthor',
      transforms: {
        authority: [
          'personauthorities',
          'person'
          ]
      },
      source_type: 'authority',
    }
    context 'and value does not start with URN' do
      it 'returns missing_terms' do
        data = ['Ann Analyst', 'Gabriel Solares']
        res = DataQualityChecker.new(mapping, data).missing_terms
        expect(res.size).to eq(2)
      end
    end
    context 'and value starts with URN' do
      it 'does not return missing_terms' do
        data = [
          "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1574450792195)'Ann Analyst'",
          "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1574683843262)'Gabriel Solares'"
        ]
        res = DataQualityChecker.new(mapping, data).missing_terms
        expect(res).to be_empty
      end
    end
  end

    context 'when source_type = vocabulary' do
    mapping = {
      fieldname: 'inventoryStatus',
      datacolumn: 'inventoryStatus',
      transforms: {
        vocabulary: 'inventorystatus'
      },
      source_type: 'vocabulary',
    }
    context 'and value does not start with URN' do
      it 'returns missing_terms' do
        data = [['newterm'], ['anothernewterm']]
        res = DataQualityChecker.new(mapping, data).missing_terms
        expect(res.size).to eq(2)
      end
    end
    context 'and value starts with URN' do
      it 'does not return missing_terms' do
        data = [
          ["urn:cspace:anthro.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'newterm'"],
          ["urn:cspace:anthro.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'anothernewterm'"]
        ]
        res = DataQualityChecker.new(mapping, data).missing_terms
        expect(res).to be_empty
      end
    end
    end

    context 'when source_type = optionlist' do
      mapping = {
        fieldname: 'collection',
        datacolumn: 'collection',
        transforms: {},
        source_type: 'optionlist',
        opt_list_values: [
          'library-collection',
          'permanent-collection',
          'study-collection',
          'teaching-collection'
        ]
      }
      context 'and value is not in option list' do
        it 'returns warning' do
          data = ['Permanent Collection']
          res = DataQualityChecker.new(mapping, data).warnings
          expect(res.size).to eq(1)
        end
      end
      context 'and value is in option list' do
        it 'does not return warning' do
          data = ['permanent-collection']
          res = DataQualityChecker.new(mapping, data).warnings
          expect(res).to be_empty
        end
      end
    end
end
