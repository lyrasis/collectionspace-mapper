# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Dates do
  before(:all) do
    @client = anthro_client
    @cache = anthro_cache
    @config = CollectionSpace::Mapper::DEFAULT_CONFIG
  end

  describe CollectionSpace::Mapper::Tools::Dates::CspaceDate do
    context 'when date string is Chronic parseable (e.g. 2020-08-14)' do
      before(:all) do
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new('2020-09-30', @client, @cache, @config)
      end
      
      it 'populates .timestamp' do
        res = @res.timestamp.to_s
        expect(res).to start_with('2020-09-30 12:00:00')
      end

      it '.mappable dateDisplayDate = 2020-09-30' do
        res = @res.mappable['dateDisplayDate']
        expect(res).to eq('2020-09-30')
      end

      it '.mappable dateEarliestSingleYear = 2020' do
        res = @res.mappable['dateEarliestSingleYear']
        expect(res).to eq('2020')
      end

      it '.mappable dateEarliestSingleMonth = 9' do
        res = @res.mappable['dateEarliestSingleMonth']
        expect(res).to eq('9')
      end

      it '.mappable dateEarliestSingleDay = 30' do
        res = @res.mappable['dateEarliestSingleDay']
        expect(res).to eq('30')
      end

      it '.mappable dateEarliestSingleEra = refname for CE' do
        res = @res.mappable['dateEarliestSingleEra']
        expect(res).to eq("urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'")
      end

      it '.mappable dateEarliestScalarValue = 2020-09-30T00:00:00.000Z' do
        res = @res.mappable['dateEarliestScalarValue']
        expect(res).to eq('2020-09-30T00:00:00.000Z')
      end

      it '.mappable dateLatestScalarValue = 2020-10-01T00:00:00.000Z' do
        res = @res.mappable['dateLatestScalarValue']
        expect(res).to eq('2020-10-01T00:00:00.000Z')
      end

      context 'when date format is ambiguous re: month/date order (e.g. 1/2/2020)' do
        before(:all) do
          @string = '1/2/2020'
        end

        context 'when no date_format specified in config' do
          it 'defaults to M/D/Y interpretation' do
            res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config).timestamp.to_s
            expect(res).to start_with('2020-01-02 12:00:00')
          end
        end
        context 'when date_format in config = month day year' do
          it 'interprets as M/D/Y' do
            res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config).timestamp.to_s
            expect(res).to start_with('2020-01-02 12:00:00')
          end
        end
        context 'when date_format in config = day month year' do
          it 'interprets as D/M/Y' do
            config = @config.merge({ date_format: 'day month year' })
            res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, config).timestamp.to_s
            expect(res).to start_with('2020-02-01 12:00:00')
          end
        end
      end
    end

    context 'when date string is not Chronic parseable (e.g. 1/2/2000 - 12/21/2001)' do
      before(:all) do
        @string = '1/2/2000 - 12/21/2001'
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config)
      end

      it '.timestamp will be nil' do
        res = @res.timestamp
        expect(res).to be_nil
      end

      it '.mappable is populated by hash from cspace-services' do
        res = @res.mappable
        expect(res).to be_a(Hash)
      end

      it 'ambiguous dates are interpreted as M/D/Y regardless of config settings' do
        expect(@res.mappable['dateEarliestSingleMonth']).to eq('1')
      end
    end

    context 'when date string is not Chronic or services parseable (e.g. VIII.XIV.MMXX)' do
      before(:all) do
        @string = 'VIII.XIV.MMXX'
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(@string, @client, @cache, @config)
      end

      it '.timestamp will be nil' do
        res = @res.timestamp
        expect(res).to be_nil
      end

      it '.mappable is populated by hash' do
        res = @res.mappable
        expect(res).to be_a(Hash)
      end

      it 'dateDisplayDate = the unparseable string' do
        expect(@res.mappable['dateDisplayDate']).to eq('VIII.XIV.MMXX')
      end

      it 'scalarValuesComputed = false' do
        expect(@res.mappable['scalarValuesComputed']).to eq('false')
      end
    end
  end
end
