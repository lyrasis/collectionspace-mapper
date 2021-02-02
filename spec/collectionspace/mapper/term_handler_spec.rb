# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::TermHandler do
  before(:all) do
    @config = CollectionSpace::Mapper::DEFAULT_CONFIG
    @client = core_client
    @cache = core_cache
    populate_core(@cache)
    @mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-collectionobject.json')
    @handler = CollectionSpace::Mapper::DataHandler.new(record_mapper: @mapper,
                                                        client: @client,
                                                        cache: @cache,
                                                        config: @config)
    @ref_mapping = {
      :fieldname=>"reference",
      :transforms=>{:authority=>["citationauthorities", "citation"]},
      :source_type=>"authority",
      :namespace=>"collectionobjects_common",
      :xpath=>["referenceGroupList", "referenceGroup"],
      :data_type=>"string",
      :required=>"n",
      :repeats=>"n",
      :in_repeating_group=>"y",
      :opt_list_values=>[],
      :datacolumn=>"referencelocal",
      :fullpath=>"collectionobjects_common/referenceGroupList/referenceGroup"
    }
    @ttl_mapping =  {
      :fieldname=>"titleTranslationLanguage",
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
      "collectionobjects_common/titleGroupList/titleGroup/titleTranslationSubGroupList/titleTranslationSubGroup"
    }
  end

  describe '#result' do
    context 'titletranslationlanguage (vocabulary, field subgroup)' do
      before(:all) do
        data = [['Ancient Greek', 'Swahili'], ['Klingon', 'Spanish']]
        @th = CollectionSpace::Mapper::TermHandler.new(mapping: @ttl_mapping, data: data, client: @client, cache: @cache, config: @config)
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
    context 'reference (authority, field group)' do
      before(:all) do
        data = ['Reference 1', 'Reference 2']
      @th = CollectionSpace::Mapper::TermHandler.new(mapping: @ref_mapping, data: data, client: @client, cache: @cache, config: @config)
      end
      it 'result is the transformed value for mapping' do
        expected = [
          "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Reference11143445083)'Reference 1'",
          "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Reference22573957271)'Reference 2'"
          ]
        expect(@th.result).to eq(expected)
      end
      it 'all values are refnames' do
        chk = @th.result.flatten.select{ |v| v.start_with?('urn:') }
        expect(chk.length).to eq(2)
      end
    end
    end
  
  describe '#terms' do
    context 'titletranslationlanguage (vocabulary, field subgroup)' do
      before(:all) do
        data = [['Ancient Greek', 'Swahili'], ['Sanza', 'Spanish']]
        @th = CollectionSpace::Mapper::TermHandler.new(mapping: @ttl_mapping, data: data, client: @client, cache: @cache, config: @config)
      end
      it 'contains a term Hash for each value' do
        expect(@th.terms.length).to eq(4)
      end
      it 'term hash :found == true when term exists already' do
        chk = @th.terms.select{ |h| h[:found] }
        expect(chk.length).to eq(3)
      end
      it 'term hash :found == false when term does not exist already' do
        chk = @th.terms.select{ |h| !h[:found] }
        expect(chk.first[:refname].display_name).to eq('Sanza')
      end
    end

    context 'reference (authority, field group)' do
      before(:all) do
        data = ['Reference 3', 'Reference 3', 'Reference 4']
        @th = CollectionSpace::Mapper::TermHandler.new(mapping: @ref_mapping, data: data, client: @client, cache: @cache, config: @config)
      end
      it 'contains a term Hash for each value' do
        expect(@th.terms.length).to eq(3)
      end
      it 'term hash :found == true when term exists already' do
        chk = @th.terms.select{ |h| h[:found] }
        expect(chk.length).to eq(1)
      end
      it 'term hash :found == false when term does not exist already' do
        chk = @th.terms.select{ |h| !h[:found] }
        expect(chk.first[:refname].display_name).to eq('Reference 3')
      end
    end
  end
  
end
