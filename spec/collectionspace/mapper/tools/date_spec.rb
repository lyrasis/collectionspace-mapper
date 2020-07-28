# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Date do
  let(:usa_date) { '11/02/1980' }
  let(:short_month_or_day_date) { '2010/1/1' }

  before(:all) do
    config = {
      delimiter: ';',
      subgroup_delimiter: '^^',
      date_element_order: 'month-day-year'
    }

    @rm_anthro_co = get_json_record_mapper(path: 'spec/fixtures/files/mappers/anthro_4_0_0-collectionobject.json')
    @dh = DataHandler.new(record_mapper: @rm_anthro_co, cache: anthro_cache, config: config)
  end

  describe Date::StructuredDate do
    context 'given empty string' do
      let(:result) { Date::StructuredDateParser.new('') }
      it 'display = nil ' do
        expect(result.display).to be_nil
      end
      it 'computed = false' do
        expect(result.computed).to be false
      end
    end

    context 'given 2011/11/02' do
      context 'date_element_order = month-day-year' do
        let(:result) { Date::StructuredDateParser.new('2011/11/02') }
        it 'display = 2011/11/02' do
          expect(result.display).to eq('2011/11/02')
        end
      end
      context 'date_element_order = day-month-year' do
        let(:result) { Date::StructuredDateParser.new('2011/11/02') }
        it 'display = 2011/11/02' do
          expect(result.display).to eq('2011/11/02')
        end
      end
    end

    context 'given date_string 2011-11-02 and end_date_string 2011-12-05' do
      it 'display = 2011-11-02 - 2011-12-05' do
        result = Date::StructuredDateParser.new('2011-11-02', '2011-12-05')
        expect(result.display).to eq('2011-11-02 - 2011-12-05')
      end
    end

    context 'given "Early 20th century"' do
      let(:result) { Date::StructuredDateParser.new('Early 20th century') }
      it 'display = Early 20th century' do
        expect(result.display).to eq('Early 20th century')
      end
      it 'computed = false' do
        expect(result.computed).to be false
      end
    end

    context 'given "ca. 1950"' do
      let(:result) { Date::StructuredDateParser.new('ca. 1950') }
      it 'display = ca. 1950' do
        expect(result.display).to eq('ca. 1950')
      end
      it 'computed = false' do
        expect(result.computed).to be false
      end
    end

    context 'when given 1905-1907' do
      let(:result) { Date::StructuredDateParser.new('1905-1907') }
      it 'keeps 1905 as start date' do
        expect(result.date_string).to eq('1905')
      end
      it 'sets 1907 as end date' do
        expect(result.end_date_string).to eq('1907')
      end
      it 'keeps original string as display value' do
        expect(result.display).to eq('1905-1907')
      end
      it 'earliest day = 1905-01-01' do
        expect(result.earliest_day).to eq('1905-01-01')
      end
      it 'latest day = 1907-12-31' do
        expect(result.latest_day).to eq('1907-12-31')
      end
    end

    context 'when given 2000-01' do
      let(:result) { Date::StructuredDateParser.new('2000-01') }
      it 'keeps 2000-01 as start date' do
        expect(result.date_string).to eq('2000-01')
      end
      it 'leaves end date nil' do
        expect(result.end_date_string).to be_nil
      end
      it 'keeps original string as display value' do
        expect(result.display).to eq('2000-01')
      end
    end

    context 'when given 2000-1-15' do
      let(:result) { Date::StructuredDateParser.new('2000-1-15') }
      it 'keeps 2000-1-15 as start date' do
        expect(result.date_string).to eq('2000-1-15')
      end
      it 'leaves end date nil' do
        expect(result.end_date_string).to be_nil
      end
      it 'keeps original string as display value' do
        expect(result.display).to eq('2000-1-15')
      end
    end

    context 'when given 2000-1-15 - 2001-1-15' do
      let(:result) { Date::StructuredDateParser.new('2000-1-15 - 2001-1-15') }
      it 'keeps 2000-1-15 - 2001-1-15 as start date' do
        expect(result.date_string).to eq('2000-1-15 - 2001-1-15')
      end
      it 'leaves end date nil' do
        expect(result.end_date_string).to be_nil
      end
      it 'keeps original string as display value' do
        expect(result.display).to eq('2000-1-15 - 2001-1-15')
      end
    end

    context 'when given 2000/1/15-2001/1/15' do
      let(:result) { Date::StructuredDateParser.new('2000/1/15-2001/1/15') }
      it 'keeps 2000/1/15 as start date' do
        expect(result.date_string).to eq('2000/1/15')
      end
      it 'sets 2001/1/15 as end date' do
        expect(result.end_date_string).to eq('2001/1/15')
      end
      it 'keeps original string as display value' do
        expect(result.display).to eq('2000/1/15-2001/1/15')
      end
    end



  end
end
