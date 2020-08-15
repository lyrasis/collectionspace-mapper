# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::ValueTransformer do
  before(:all) do
    @cache = anthro_cache
  end

  context 'when authority' do
    context 'when term exists' do
    it 'returns refname urn' do
      value = 'Blackfoot'
      transforms = { authority: %w[conceptauthorities archculture] }
      res = ValueTransformer.new(value, transforms, @cache).result
      ex = /urn:cspace:anthro.collectionspace.org:conceptauthorities:name\(archculture\):item:name\(Blackfoot\d+\)'Blackfoot'/
      expect(res).to match(ex)
    end
    end
    context 'when term does not exist' do
      before(:all) do
        @string = [*('a'..'z'),*('A'..'Z')].shuffle[0,10].join
        @transforms = { authority: %w[conceptauthorities archculture] }
        @result = ValueTransformer.new(@string, @transforms, @cache).result
      end
      it 'returns original value' do
        expect(@result).to eq(@string)
      end
    end
  end

  context 'when vocabulary' do
    it 'returns refname urn' do
      value = 'Chinese'
      transforms = { vocabulary: 'languages' }
      res = ValueTransformer.new(value, transforms, @cache).result
      ex = "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(zho)'Chinese'"
      expect(res).to eq(ex)
    end

    context 'and vocabulary is behrensmeyer number' do
      it 'returns correct refname urn' do
        value = '0'
        transforms = { vocabulary: 'behrensmeyer', special: %w[behrensmeyer_translate] }
        res = ValueTransformer.new(value, transforms, @cache).result
        ex = "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(0)'0 - no cracking or flaking on bone surface'"
        expect(res).to eq(ex)
      end
    end

    context 'and vocabulary is agerange' do
      context 'and term given = Adolescent 26 - 75%' do
        it 'returns correct refname urn' do
          value = 'Adolescent 26 - 75%'
          transforms = { vocabulary: 'agerange', special: %w[downcase_value],
                        replacements: [
                          { find: ' - ', replace: '-', type: :plain }
                        ]
                       }
          res = ValueTransformer.new(value, transforms, @cache).result
          ex = "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adolescent_26_75)'adolescent 26-75%'"
          expect(res).to eq(ex)
        end
      end
    end
  end

  context 'when replacements' do
    it 'does replacements' do
      value = 'rice plant'
      transforms = {
        replacements: [
          { find: '[aeiou]', replace: 'y', type: :regexp },
          { find: ' ', replace: '%%', type: :plain }
        ]
      }
      res = ValueTransformer.new(value, transforms, @cache).result
      expect(res).to eq('rycy%%plynt')
    end
  end
  
end



