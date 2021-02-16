# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Config do
  it 'symbolizes config hash correctly' do
    config = '{
  "delimiter": ";",
  "subgroup_delimiter": "^^",
  "response_mode": "verbose",
  "force_defaults": false,
  "check_record_status": true,
  "check_terms": true,
  "transforms": {
    "collection": {
      "special": [
        "downcase_value"
      ],
      "replacements": [{
        "find": " ",
        "replace": "-",
        "type": "plain"
      }]
    }
  },
  "default_values": {
    "publishTo": "DPLA;Omeka",
    "collection": "library-collection"
  },
  "ambiguous_month_day": "as_month_day",
  "ambiguous_month_year": "as_year"
}'
    expected = {:delimiter=>";", :subgroup_delimiter=>"^^", :response_mode=>"verbose", :force_defaults=>false, :check_record_status=>true, :check_terms=>true, :transforms=>{"collection"=>{:special=>["downcase_value"], :replacements=>[{:find=>" ", :replace=>"-", :type=>"plain"}]}}, :default_values=>{"publishTo"=>"DPLA;Omeka", "collection"=>"library-collection"}, :ambiguous_month_day=>:as_month_day, :ambiguous_month_year=>:as_year}
    result = CollectionSpace::Mapper::Tools::Config.new(config).hash
    expect(result).to eq(expected)
  end

  describe '#date_config' do
    it 'extracts emendate options correctly' do
      config = CollectionSpace::Mapper::DEFAULT_CONFIG.merge(Emendate::Options.new.options)
      expected = {:ambiguous_month_day=>:as_month_day,
                  :ambiguous_month_year=>:as_year,
                  :two_digit_year_handling=>:coerce,
                  :ambiguous_year_rollback_threshold=>21,
                  :square_bracket_interpretation=>:supplied_date,
                  :pluralized_date_interpretation=>:decade}
      result = CollectionSpace::Mapper::Tools::Config.new(config)
      expect(result.date_config).to eq(expected)
    end
    it 'returns empty hash if no Emendate options given' do
      config = CollectionSpace::Mapper::DEFAULT_CONFIG
      expected = {}
      result = CollectionSpace::Mapper::Tools::Config.new(config)
      expect(result.date_config).to eq(expected)
    end
  end
end


