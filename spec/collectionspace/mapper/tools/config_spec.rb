# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CollectionSpace::Mapper::Tools::Config do
  before(:all) do
    @config = '{
  "delimiter": ";",
  "subgroup_delimiter": "^^",
  "response_mode": "verbose",
  "force_defaults": false,
  "check_record_status": true,
  "check_terms": true,
  "date_format": "month day year",
  "two_digit_year_handling": "convert to four digit",
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
  }
}'
  end
  
  it 'symbolizes config hash correctly' do
    expected = {:delimiter=>";", :subgroup_delimiter=>"^^", :response_mode=>"verbose", :force_defaults=>false, :check_record_status=>true, :check_terms=>true, :date_format=>"month day year", :two_digit_year_handling=>"convert to four digit", :transforms=>{"collection"=>{:special=>["downcase_value"], :replacements=>[{:find=>" ", :replace=>"-", :type=>"plain"}]}}, :default_values=>{"publishTo"=>"DPLA;Omeka", "collection"=>"library-collection"}}
      result = CollectionSpace::Mapper::Tools::Config.new(@config).hash
      expect(result).to eq(expected)
    end
  end


