require 'collectionspace/mapper/version'
require 'collectionspace/client'
require 'collectionspace/refcache'

require 'benchmark'
require 'json'
require 'logger'
require 'pp'

require 'facets/array/before'
require 'facets/kernel/blank'
require 'nokogiri'
require 'xxhash'

require 'ruby-prof'

module CollectionSpace
  module Mapper
    extend self
    LOGGER = Logger.new(STDERR)
    DEFAULT_CONFIG = { delimiter: '|',
                       subgroup_delimiter: '^^',
                       response_mode: 'normal',
                       check_terms: true,
                       check_record_status: true,
                       force_defaults: false,
                       date_format: 'month day year',
                       two_digit_year_handling: 'coerce'
                     }

    # mixins
    require 'collectionspace/mapper/term_searchable'

    require 'collectionspace/mapper/data_prepper'
    require 'collectionspace/mapper/authority_hierarchy_prepper'
    require 'collectionspace/mapper/column_mapping'
    require 'collectionspace/mapper/column_mappings'
    require 'collectionspace/mapper/data_handler'
    require 'collectionspace/mapper/data_mapper'
    require 'collectionspace/mapper/data_quality_checker'
    require 'collectionspace/mapper/data_splitter'
    require 'collectionspace/mapper/data_validator'
    require 'collectionspace/mapper/non_hierarchical_relationship_prepper'
    require 'collectionspace/mapper/record_mapper'
    require 'collectionspace/mapper/response'
    require 'collectionspace/mapper/term_handler'
    require 'collectionspace/mapper/value_transformer'

    require 'collectionspace/mapper/identifiers/short_identifier'
    require 'collectionspace/mapper/identifiers/authority_short_identifier'

    require 'collectionspace/mapper/tools/config'
    require 'collectionspace/mapper/tools/dates'
    require 'collectionspace/mapper/tools/refname'
    require 'collectionspace/mapper/tools/record_status_service'

    module Errors
        class UnprocessableDataError < StandardError
          UnprocessableDataError = CollectionSpace::Mapper::Errors::UnprocessableDataError
        attr_reader :input
        def initialize(message, input)
          super(message)
          @input = input
        end
      end
    end

    def setup_data(data, defaults = {}, config = DEFAULT_CONFIG)
      if data.is_a?(Hash)
        response = Response.new(data)
      elsif data.is_a?(CollectionSpace::Mapper::Response)
        response = data
      else
        raise Errors::UnprocessableDataError.new("Cannot process a #{data.class}. Need a Hash or Mapper::Response", data)
      end

      response.merged_data.empty? ? merge_default_values(response, defaults, config) : response
    end

    def merge_default_values(data, defaults, config)
      mdata = data.orig_data.clone
      defaults.each do |f, val|
        if config[:force_defaults]
          mdata[f] = val
        else
          dataval = data.orig_data.fetch(f, nil)
          mdata[f] = val if dataval.nil? || dataval.empty?
        end
      end
      data.merged_data = mdata.compact.transform_keys(&:downcase)
      data
    end
    
    def term_key(term)
      "#{term[:refname].type}-#{term[:refname].subtype}-#{term[:refname].display_name}"
    end

  end    
end
