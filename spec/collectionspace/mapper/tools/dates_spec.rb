# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Dates do
  before(:all) do
    @client = anthro_client
    @cache = anthro_cache
    @fcart_client = fcart_client
    @fcart_cache = fcart_cache
    @config = CollectionSpace::Mapper::DEFAULT_CONFIG.merge(Emendate::Options.new.options)
  end

  describe CollectionSpace::Mapper::Tools::Dates::CspaceDate do
    context '%NULLVALUE%' do
      before(:all) do
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: '%NULLVALUE%', client: @client, cache: @cache, config: @config)
      end
      
      it '#stamp is nil' do
        res = @res.stamp
        expect(res).to be_nil
      end

      it '#mappable is empty hash' do
        res = @res.mappable
        expect(res).to eq({})
      end
    end

    context 'when date string is not parseable' do
      context 'date = VIII.XIV.MMXX' do
        before(:all) do
          @string = 'VIII.XIV.MMXX'
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: @config)
        end

        it '#stamp is nil' do
          res = @res.stamp
          expect(res).to be_nil
        end

        it 'dateDisplayDate = the unparseable string' do
          expect(@res.mappable['dateDisplayDate']).to eq('VIII.XIV.MMXX')
        end

        it 'scalarValuesComputed = false' do
          expect(@res.mappable['scalarValuesComputed']).to eq('false')
        end
      end
    end
    
    context 'n.d.' do
      context 'anthro client (does not have "no date" datecertainty vocab term)' do
        before(:all) do
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: 'n.d.', client: @client, cache: @cache, config: @config)
        end
        
        it '#stamp is nil' do
          res = @res.stamp
          expect(res).to be_nil
        end

        it 'dateDisplayDate = the unparseable string' do
          expect(@res.mappable['dateDisplayDate']).to eq('n.d.')
        end

        it 'scalarValuesComputed = false' do
          expect(@res.mappable['scalarValuesComputed']).to eq('false')
        end
      end
      context 'fcart client (has "no date" datecertainty vocab term)' do
        before(:all) do
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: 'n.d.', client: @fcart_client, cache: @fcart_cache, config: @config)
        end
        
        it '#stamp is nil' do
          res = @res.stamp
          expect(res).to be_nil
        end

        it 'dateDisplayDate = n.d.' do
          expect(@res.mappable['dateDisplayDate']).to eq('n.d.')
        end

        it 'scalarValuesComputed = false' do
          expect(@res.mappable['scalarValuesComputed']).to eq('false')
        end

        it 'dateEarliestSingleCertainty = no date refname' do
          refname = "urn:cspace:fcart.collectionspace.org:vocabularies:name(datecertainty):item:name(nodate)'no date'"
          expect(@res.mappable['dateEarliestSingleCertainty']).to eq(refname)
        end
      end
    end

    context '2020-09-30' do
      before(:all) do
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: '2020-09-30', client: @client, cache: @cache, config: @config)
      end
      
      it '#stamp = 2020-09-30T00:00:00.000Z' do
        res = @res.stamp
        expect(res).to eq('2020-09-30T00:00:00.000Z')
      end

      it '#mappable dateDisplayDate = 2020-09-30' do
        res = @res.mappable['dateDisplayDate']
        expect(res).to eq('2020-09-30')
      end

      it '#mappable dateEarliestSingleYear = 2020' do
        res = @res.mappable['dateEarliestSingleYear']
        expect(res).to eq('2020')
      end

      it '#mappable dateEarliestSingleMonth = 9' do
        res = @res.mappable['dateEarliestSingleMonth']
        expect(res).to eq('9')
      end

      it '#mappable dateEarliestSingleDay = 30' do
        res = @res.mappable['dateEarliestSingleDay']
        expect(res).to eq('30')
      end

      it '#mappable dateEarliestSingleEra = refname for CE' do
        res = @res.mappable['dateEarliestSingleEra']
        expect(res).to eq("urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'")
      end

      it '#mappable dateEarliestScalarValue = 2020-09-30T00:00:00.000Z' do
        res = @res.mappable['dateEarliestScalarValue']
        expect(res).to eq('2020-09-30T00:00:00.000Z')
      end

      it '#mappable dateLatestScalarValue = 2020-09-30T00:00:00.000Z' do
        res = @res.mappable['dateLatestScalarValue']
        expect(res).to eq('2020-09-30T00:00:00.000Z')
      end
    end

    context 'when date format is ambiguous re: month/date order (e.g. 1/2/2020)' do
      before(:all) do
        @string = '1/2/2020'
      end

      context 'ambiguous_month_day not explicitly set' do
        it 'defaults to M/D/Y interpretation' do
          res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: @config)
          expect(res.mappable['dateEarliestScalarValue']).to start_with('2020-01-02')
        end
      end
      context 'ambiguous_month_day: :as_month_day' do
        it 'interprets as M/D/Y' do
          config = @config.merge({ambiguous_month_day: :as_month_day})
          res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: config)
          expect(res.mappable['dateEarliestScalarValue']).to start_with('2020-01-02')
        end
      end
      context 'ambiguous_month_day: :as_day_month' do
        it 'interprets as D/M/Y' do
          config = @config.merge({ambiguous_month_day: :as_day_month})
          res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: config)
          expect(res.mappable['dateEarliestScalarValue']).to start_with('2020-02-01')
        end
      end
    end


    context 'when date string has two-digit year (e.g. 9/19/91)' do
      before(:all) do
        @string = '9/19/91'
      end

      context 'when config[:two_digit_year_handling] = coerce' do
        before(:all) do
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: @config)
        end

        it 'Parses date with coerced 4-digit year' do
          expect(@res.mappable['dateEarliestSingleYear']).to eq('1991')
        end
      end

      context 'when config[:two_digit_year_handling] = literal' do
        before(:all) do
          config = @config.merge({two_digit_year_handling: :literal})
          @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, config: config, cache: @cache)
        end

        it 'Services parses date with uncoerced 2-digit year' do
          expect(@res.mappable['dateEarliestSingleYear']).to eq('91')
        end
      end
    end
    
    context '1/2/2000 - 12/21/2001' do
      before(:all) do
        @string = '1/2/2000 - 12/21/2001'
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: @config)
      end

      it '#stamp = 2000-01-02T00:00:00.000Z' do
        res = @res.stamp
        expect(res).to eq('2000-01-02T00:00:00.000Z')
      end
      it '#mappable dateDisplayDate = 1/2/2000 - 12/21/2001' do
        res = @res.mappable['dateDisplayDate']
        expect(res).to eq('1/2/2000 - 12/21/2001')
      end

      it '#mappable dateEarliestSingleYear = 2000' do
        res = @res.mappable['dateEarliestSingleYear']
        expect(res).to eq('2000')
      end

      it '#mappable dateEarliestSingleMonth = 1' do
        res = @res.mappable['dateEarliestSingleMonth']
        expect(res).to eq('1')
      end

      it '#mappable dateEarliestSingleDay = 2' do
        res = @res.mappable['dateEarliestSingleDay']
        expect(res).to eq('2')
      end

      it '#mappable dateEarliestSingleEra = refname for CE' do
        res = @res.mappable['dateEarliestSingleEra']
        expect(res).to eq("urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'")
      end
      
      it '#mappable dateEarliestScalarValue = 2000-01-02T00:00:00.000Z' do
        res = @res.mappable['dateEarliestScalarValue']
        expect(res).to eq('2000-01-02T00:00:00.000Z')
      end

      it '#mappable dateLatestYear = 2001' do
        res = @res.mappable['dateLatestYear']
        expect(res).to eq('2001')
      end

      it '#mappable dateLatestMonth = 12' do
        res = @res.mappable['dateLatestMonth']
        expect(res).to eq('12')
      end

      it '#mappable dateLatestDay = 21' do
        res = @res.mappable['dateLatestDay']
        expect(res).to eq('21')
      end

      it '#mappable dateLatestEra = refname for CE' do
        res = @res.mappable['dateLatestEra']
        expect(res).to eq("urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'")
      end

      it '#mappable dateLatestScalarValue = 2001-12-21T00:00:00.000Z' do
        res = @res.mappable['dateLatestScalarValue']
        expect(res).to eq('2001-12-21T00:00:00.000Z')
      end
    end

    context 'when date string = march 2020' do
      before(:all) do
        @string = 'march 2020'
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: @config)
      end

      it 'dateEarliestScalarValue = 2020-03-01T00:00:00.000Z' do
        expect(@res.mappable['dateEarliestScalarValue']).to eq('2020-03-01T00:00:00.000Z')
      end

      it 'dateLatestScalarValue = 2020-03-31T00:00:00.000Z' do
        expect(@res.mappable['dateLatestScalarValue']).to eq('2020-03-31T00:00:00.000Z')
      end

      it 'dateEarliestSingleMonth = 3' do
        expect(@res.mappable['dateEarliestSingleMonth']).to eq('3')
      end
      
      it 'dateLatestMonth = 3' do
        expect(@res.mappable['dateLatestMonth']).to eq('3')
      end

      it 'dateEarliestSingleDay = 1' do
        expect(@res.mappable['dateEarliestSingleDay']).to eq('1')
      end
      
      it 'dateLatestDay = 31' do
        expect(@res.mappable['dateLatestDay']).to eq('31')
      end

      it 'dateEarliestSingleYear = 2020' do
        expect(@res.mappable['dateEarliestSingleYear']).to eq('2020')
      end
      
      it 'dateLatestYear = 2020' do
        expect(@res.mappable['dateLatestYear']).to eq('2020')
      end
    end

    context 'when date string = 2020-03' do
      before(:all) do
        @string = '2020-03'
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: @config)
      end

      it 'dateEarliestScalarValue = 2020-03-01T00:00:00.000Z' do
        expect(@res.mappable['dateEarliestScalarValue']).to eq('2020-03-01T00:00:00.000Z')
      end

      it 'dateLatestScalarValue = 2020-03-31T00:00:00.000Z' do
        expect(@res.mappable['dateLatestScalarValue']).to eq('2020-03-31T00:00:00.000Z')
      end

      it 'dateEarliestSingleMonth = 3' do
        expect(@res.mappable['dateEarliestSingleMonth']).to eq('3')
      end
      
      it 'dateLatestMonth = 3' do
        expect(@res.mappable['dateLatestMonth']).to eq('3')
      end

      it 'dateEarliestSingleDay = 1' do
        expect(@res.mappable['dateEarliestSingleDay']).to eq('1')
      end
      
      it 'dateLatestDay = 31' do
        expect(@res.mappable['dateLatestDay']).to eq('31')
      end

      it 'dateEarliestSingleYear = 2020' do
        expect(@res.mappable['dateEarliestSingleYear']).to eq('2020')
      end
      
      it 'dateLatestYear = 2020' do
        expect(@res.mappable['dateLatestYear']).to eq('2020')
      end
    end

    context 'when date string = 2002' do
      before(:all) do
        @string = '2002'
        @res = CollectionSpace::Mapper::Tools::Dates::CspaceDate.new(date_string: @string, client: @client, cache: @cache, config: @config)
      end

      it 'dateEarliestScalarValue = 2002-01-01T00:00:00.000Z' do
        expect(@res.mappable['dateEarliestScalarValue']).to eq('2002-01-01T00:00:00.000Z')
      end

      it 'dateLatestScalarValue = 2002-12-31T00:00:00.000Z' do
        expect(@res.mappable['dateLatestScalarValue']).to eq('2002-12-31T00:00:00.000Z')
      end

      it 'dateEarliestSingleMonth = 1' do
        expect(@res.mappable['dateEarliestSingleMonth']).to eq('1')
      end
      
      it 'dateLatestMonth = 12' do
        expect(@res.mappable['dateLatestMonth']).to eq('12')
      end

      it 'dateEarliestSingleDay = 1' do
        expect(@res.mappable['dateEarliestSingleDay']).to eq('1')
      end
      
      it 'dateLatestDay = 31' do
        expect(@res.mappable['dateLatestDay']).to eq('31')
      end

      it 'dateEarliestSingleYear = 2002' do
        expect(@res.mappable['dateEarliestSingleYear']).to eq('2002')
      end
      
      it 'dateLatestYear = 2002' do
        expect(@res.mappable['dateLatestYear']).to eq('2002')
      end
    end
  end
end
