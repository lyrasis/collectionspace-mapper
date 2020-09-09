# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::DataPrepper do
  before(:all) do
    @config = Mapper::DEFAULT_CONFIG
  end
  
  context 'anthro profile' do
    before(:all) do
      @client = anthro_client
      @cache = anthro_cache
      populate_anthro(@cache)
      @collectionobject_config = @config.merge({
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
      })

      @collectionobject_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_0/anthro/anthro_4_0_0-collectionobject.json')
      @handler = DataHandler.new(record_mapper: @collectionobject_mapper, cache: @cache, client: @client, config: @collectionobject_config)
      @prepper = DataPrepper.new(anthro_co_1, @handler)
    end

    describe '#merge_default_values' do
      context 'when no default_values specified in config' do
        it 'does not fall over' do
          dh = DataHandler.new(record_mapper: @collectionobject_mapper, cache: anthro_cache, client: anthro_client, config: @config)
          populate_anthro(dh.cache)
          dp = DataPrepper.new(anthro_co_1, @handler)
          res = dp.prep.merged_data['collection']
          ex = 'Permanent Collection'
          expect(res).to eq(ex)
        end
      end
      context 'when default_values for a field is specified in config' do
        context 'and no value is given for that field in the incoming data' do
          it 'maps the default values' do
            res = @prepper.prep.merged_data['publishto']
            ex = "DPLA;Omeka"
            expect(res).to eq(ex)
          end
        end
        context 'and value is given for that field in the incoming data' do
          context 'and :force_defaults = false' do
            it 'maps the value in the incoming data' do
              res = @prepper.prep.merged_data['collection']
              ex = 'Permanent Collection'
              expect(res).to eq(ex)
            end
          end
          context 'and :force_defaults = true' do
            it 'maps the default value, overwriting value in the incoming data' do
              config = Mapper::DEFAULT_CONFIG.merge({
                default_values: {
                  'collection' => 'library-collection'
                },
                force_defaults: true,
              })
              dh = DataHandler.new(record_mapper: @collectionobject_mapper, cache: @cache, client: @client, config: config)
              dp = DataPrepper.new(anthro_co_1, dh)
              res = dp.prep.merged_data['collection']
              ex = 'library-collection'
              expect(res).to eq(ex)
            end
          end
        end
      end
    end

    describe '#process_xpaths' do
      context 'when authority record' do
        before(:all) do
          @place_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-place.json')
          @place_handler = DataHandler.new(record_mapper: @place_mapper, cache: core_cache, client: core_client, config: @config)
          data = get_datahash(path: 'spec/fixtures/files/datahashes/core/place001.json')
          @place_prepper = DataPrepper.new(data, @place_handler)
        end
        it 'keeps mapping for shortIdentifier in xphash' do
          @place_prepper.prep
          result = @place_prepper.xphash['places_common'][:mappings].select do |mapping|
            mapping[:fieldname] == 'shortIdentifier'
          end
          expect(result.length).to eq(1)
        end
      end
    end

    describe '#transform_date_fields' do
      context 'when field is a structured date' do
        it 'results in mappable structured date hashes' do
          res = @prepper.prep.transformed_data['identdategroup']
          chk = res.map{ |e| e.class }.uniq
          expect(chk).to eq([Hash])
        end
      end
      context 'when field is an unstructured date' do
        it 'results in array of datestamp strings' do
          res = @prepper.prep.transformed_data['annotationdate']
          chk = res.select{ |e| e['T00:00:00.000Z'] }
          expect(chk.size).to eq(2)
        end
      end
    end

    describe '#combine_data_values' do
      context 'when multi-authority field is not part of repeating field group' do
        it 'combines values properly' do
          xpath = 'collectionobjects_common/fieldCollectors'
          result = @prepper.prep.combined_data[xpath]['fieldCollector']
          expected = ["urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'",
                      "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1594848906847)'Gabriel Solares'",
                      "urn:cspace:anthro.collectionspace.org:orgauthorities:name(organization):item:name(Organization11587136583004)'Organization 1'"]
          expect(result).to eq(expected)
        end
      end
      context 'when multi-authority field is part of repeating field group' do
        it 'combines values properly' do
          xpath = 'collectionobjects_common/objectProductionPeopleGroupList/objectProductionPeopleGroup'
          result = @prepper.prep.combined_data[xpath]['objectProductionPeople']
          expected = [
            "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(archculture):item:name(Blackfoot1576172504869)'Blackfoot'",
            "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Batak1576172496916)'Batak'"
          ]
          expect(result).to eq(expected)
        end

        context 'and one or more combined field values is blank' do
          before(:all) do
            @core_conservation_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-conservation.json')
            @handler = DataHandler.new(record_mapper: @core_conservation_mapper, cache: core_cache, client: core_client, config: @config)
            populate_core(@handler.cache)
            data = get_datahash(path: 'spec/fixtures/files/datahashes/core/conservation0_1.json')
            @prepper = DataPrepper.new(data, @handler)
            @xpath = 'conservation_common/conservationStatusGroupList/conservationStatusGroup'
          end
          it 'removes empty fields from combined data response' do
            result = @prepper.prep.combined_data[@xpath].keys
            expect(result).to_not include('statusDate')
          end
          it 'removes empty fields from fieldmapping list passed on for mapping' do
            @prepper.prep
            result = @prepper.xphash[@xpath][:mappings]
            expect(result.length).to eq(1)
          end
        end
      end
      context 'when multi-authority field is part of repeating field subgroup' do
        before(:all) do
          @core_media_mapper = get_json_record_mapper(path: 'spec/fixtures/files/mappers/release_6_1/core/core_6_1_0-media.json')
          @handler = DataHandler.new(record_mapper: @core_media_mapper, cache: core_cache, client: core_client, config: @config)
          populate_core(@handler.cache)
        end
        
        context 'when there is more than one group' do
          before(:all) do
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
        context 'when there is only one group' do
          before(:all) do
            data = get_datahash(path: 'spec/fixtures/files/datahashes/core/media1_2.json')
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
            ]
            expect(result).to eq(expected)
          end
        end      
      end
    end

    describe '#prep' do
      before(:all) do
        @res = @prepper.prep
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
        expect(@prepper.check_data).to be_a(Array)
      end
    end
  end
end
