# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataPrepper do
  before(:all) do
    @config = {
      delimiter: ';',
      subgroup_delimiter: '^^',
      transforms: {
        'collection' => {
          special: %w[downcase_value],
          replacements: [
            { find: ' ', replace: '-', type: :plain }
          ]
        },
        'ageRange' => {
          special: %w[downcase_value],
        }
      },
      default_values: {
        'publishTo' => 'DPLA;Omeka',
        'collection' => 'library-collection'
      },
      force_defaults: false
    }

    @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_0/anthro/anthro_4_0_0-collectionobject.json')
    @dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, client: anthro_client, config: @config)
    populate_anthro(@dh.cache)
    @dp = DataPrepper.new(anthro_co_1, @dh)
  end

  describe '#merge_default_values' do
    context 'when no default_values specified in config' do
      it 'does not fall over' do
        config = {
          delimiter: ';',
          subgroup_delimiter: '^^',
          force_defaults: false
        }
        dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, client: anthro_client, config: config)
        populate_anthro(dh.cache)
        dp = DataPrepper.new(anthro_co_1, @dh)
        res = dp.prep.merged_data['collection']
        ex = 'Permanent Collection'
        expect(res).to eq(ex)
      end
    end
    context 'when default_values for a field is specified in config' do
      context 'and no value is given for that field in the incoming data' do
        it 'maps the default values' do
          res = @dp.prep.merged_data['publishto']
          ex = "DPLA;Omeka"
          expect(res).to eq(ex)
        end
      end
      context 'and value is given for that field in the incoming data' do
        context 'and :force_defaults = false' do
          it 'maps the value in the incoming data' do
            res = @dp.prep.merged_data['collection']
            ex = 'Permanent Collection'
            expect(res).to eq(ex)
          end
        end
        context 'and :force_defaults = true' do
          it 'maps the default value, overwriting value in the incoming data' do
            config = {
              delimiter: ';',
              subgroup_delimiter: '^^',
              default_values: {
                'collection' => 'library-collection'
              },
              force_defaults: true
            }
            dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, client: anthro_client, config: config)
            dp = DataPrepper.new(anthro_co_1, dh)
            res = dp.prep.merged_data['collection']
            ex = 'library-collection'
            expect(res).to eq(ex)
          end
        end
      end
    end
  end

  describe '#transform_date_fields' do
    context 'when field is a structured date' do
      it 'results in mappable structured date hashes' do
        res = @dp.prep.transformed_data['identdategroup']
        chk = res.map{ |e| e.class }.uniq
        expect(chk).to eq([Hash])
      end
    end
    context 'when field is an unstructured date' do
      it 'results in array of datestamp strings' do
        res = @dp.prep.transformed_data['annotationdate']
        chk = res.select{ |e| e['T00:00:00.000Z'] }
        expect(chk.size).to eq(2)
      end
    end
  end

    describe '#combine_data_values' do
    context 'when multi-authority field is not part of repeating field group' do
      it 'combines values properly' do
        xpath = 'collectionobjects_common/fieldCollectors'
        result = @dp.prep.combined_data[xpath]['fieldCollector']
        expected = ["urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'",
     "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1594848906847)'Gabriel Solares'",
     "urn:cspace:anthro.collectionspace.org:orgauthorities:name(organization):item:name(Organization11587136583004)'Organization 1'"]
        expect(result).to eq(expected)
      end
    end
    context 'when multi-authority field is part of repeating field group' do
      it 'combines values properly' do
        xpath = 'collectionobjects_common/objectProductionPeopleGroupList/objectProductionPeopleGroup'
        result = @dp.prep.combined_data[xpath]['objectProductionPeople']
        expected = [
          "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(archculture):item:name(Blackfoot1576172504869)'Blackfoot'",
          "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Batak1576172496916)'Batak'"
        ]
        expect(result).to eq(expected)
      end
    end
    context 'when multi-authority field is part of repeating field subgroup' do
      before(:all) do
        @core_media_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-media.json')
        @handler = DataHandler.new(record_mapper: @core_media_mapper, cache: core_cache, client: core_client, config: @config)
        populate_core(@handler.cache)
        data = get_datahash(path: 'spec/fixtures/files/datahashes/core/media1_1.json')
        @prepper = DataPrepper.new(data, @handler)
      end
      it 'combines values properly' do
        xpath = 'media_common/measuredPartGroupList/measuredPartGroup/dimensionSubGroupList/dimensionSubGroup'
        result = @prepper.prep.combined_data[xpath]['measuredBy']
        expected = [
          [
          "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'",
          "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Comodore1599463826401)'Comodore'",
          "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
          ""],
          [
          "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'",
          "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'",
          ]          
        ]
        expect(result).to eq(expected)
      end
    end
  end

  describe '#prep' do
    before(:all) do
      @res = @dp.prep
    end
    it 'returns Mapper::Response object' do
      expect(@res).to be_a(Mapper::Response)
    end
    it 'contains orig data hash' do
      expect(@res.orig_data).not_to be_empty
    end
    it 'contains merged data hash' do
      expect(@res.merged_data).not_to be_empty
    end
    it 'contains split data hash' do
      expect(@res.split_data).not_to be_empty
    end
    it 'contains transformed data hash' do
      expect(@res.transformed_data).not_to be_empty
    end
    it 'contains combined data hash' do
      expect(@res.combined_data).not_to be_empty
    end
  end

  describe '#check_data' do
    it 'returns array' do
      expect(@dp.check_data).to be_a(Array)
    end
  end

end
