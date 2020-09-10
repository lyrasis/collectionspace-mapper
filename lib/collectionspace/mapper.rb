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
    ::Mapper = CollectionSpace::Mapper

    LOGGER = Logger.new(STDERR)
    DEFAULT_CONFIG = { delimiter: ';',
                       subgroup_delimiter: '^^',
                       response_mode: 'normal',
                       force_defaults: false,
                       date_format: 'month day year'
                     }

    require 'collectionspace/mapper/data_handler'
    require 'collectionspace/mapper/data_mapper'
    require 'collectionspace/mapper/data_prepper'
    require 'collectionspace/mapper/data_quality_checker'
    require 'collectionspace/mapper/data_splitter'
    require 'collectionspace/mapper/data_validator'
    require 'collectionspace/mapper/response'
    require 'collectionspace/mapper/value_transformer'

    require 'collectionspace/mapper/tools/authorities'
    require 'collectionspace/mapper/tools/config'
    require 'collectionspace/mapper/tools/dates'
    require 'collectionspace/mapper/tools/identifiers'
    require 'collectionspace/mapper/tools/record_mapper'
    require 'collectionspace/mapper/tools/vocabularies'

    module Errors
      ::Errors = CollectionSpace::Mapper::Errors
      class UnprocessableDataError < StandardError; end
    end

    def self.setup_data(data)
      if data.is_a?(Hash)
        Response.new(data)
      elsif data.is_a?(CollectionSpace::Mapper::Response)
        data
      else
        raise UnprocessableDataError.new("Cannot process a #{data.class}. Need a Hash or Mapper::Response")
      end
    end

  end    
end
