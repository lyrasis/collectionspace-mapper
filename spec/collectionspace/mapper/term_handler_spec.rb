# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::TermHandler do
  before(:all) do
    @config = Mapper::DEFAULT_CONFIG
    @client = core_client
    @cache = core_cache
    populate_core(@cache)
    @mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-collectionobject.json')
    @handler = DataHandler.new(@mapper, @client, @cache)

    @mapping =  {:fieldname=>"titleTranslationLanguage",
                 :transforms=>{:vocabulary=>"languages"},
                 :source_type=>"vocabulary",
                 :namespace=>"collectionobjects_common",
                 :xpath=>
                 ["titleGroupList",
                  "titleGroup",
                  "titleTranslationSubGroupList",
                  "titleTranslationSubGroup"],
                 :data_type=>"string",
                 :required=>"n",
                 :repeats=>"n",
                 :in_repeating_group=>"y",
                 :opt_list_values=>[],
                 :datacolumn=>"titletranslationlanguage",
                 :fullpath=>
                 "collectionobjects_common/titleGroupList/titleGroup/titleTranslationSubGroupList/titleTranslationSubGroup"}
  end

  describe '#result' do
    context 'titletranslationlanguage example' do
      before(:all) do
        data = [['Ancient Greek', 'Swahili'], ['Klingon', 'Spanish']]
        @th = TermHandler.new(@mapping, data, @cache)
      end
    it 'result is the transformed value for mapping' do
      expected = [["urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(grc)'Ancient Greek'",
                   "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(swa)'Swahili'"],
                  ["urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(Klingon)'Klingon'",
                   "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'"]]
      expect(@th.result).to eq(expected)
    end
    it 'all values are refnames' do
      chk = @th.result.flatten.select{ |v| v.start_with?('urn:') }
      expect(chk.length).to eq(4)
    end
    end
    end
  
  describe '#terms' do
    context 'titletranslationlanguage example' do
      before(:all) do
        data = [['Ancient Greek', 'Swahili'], ['Klingon', 'Spanish']]
        @th = TermHandler.new(@mapping, data, @cache)
      end
      it 'contains a term Hash for each value' do
        pp(@th.terms)
        expect(@th.terms.length).to eq(4)
      end
      it 'term hash :found == true when term exists already' do
        chk = @th.terms.select{ |h| h[:found] }
        expect(chk.length).to eq(3)
      end
      it 'term hash :found == false when term does not exist already' do
        chk = @th.terms.select{ |h| !h[:found] }
        expect(chk.first[:value]).to eq('Klingon')
      end
    end
  end
  
end
