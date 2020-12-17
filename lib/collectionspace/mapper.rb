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

module CollectionSpace
  module Mapper
    extend self
    LOGGER = Logger.new(STDERR)
    DEFAULT_CONFIG = { delimiter: '|',
                       subgroup_delimiter: '^^',
                       response_mode: 'normal',
                       force_defaults: false,
                       date_format: 'month day year',
                       two_digit_year_handling: 'coerce'
                     }

    require 'collectionspace/mapper/data_handler'
    require 'collectionspace/mapper/data_mapper'
    require 'collectionspace/mapper/data_prepper'
    require 'collectionspace/mapper/data_quality_checker'
    require 'collectionspace/mapper/data_splitter'
    require 'collectionspace/mapper/data_validator'
    require 'collectionspace/mapper/response'
    require 'collectionspace/mapper/term_handler'
    require 'collectionspace/mapper/value_transformer'

    require 'collectionspace/mapper/tools/config'
    require 'collectionspace/mapper/tools/dates'
    require 'collectionspace/mapper/tools/identifiers'
    require 'collectionspace/mapper/tools/record_mapper'
    require 'collectionspace/mapper/tools/refname'

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

    def setup_data(data)
      if data.is_a?(Hash)
        Response.new(data)
      elsif data.is_a?(CollectionSpace::Mapper::Response)
        data
      else
        #begin
          raise Errors::UnprocessableDataError.new("Cannot process a #{data.class}. Need a Hash or Mapper::Response", data)
        # rescue Errors::UnprocessableDataError => error
        #   error.set_backtrace([])
        #   CollectionSpace::Mapper::LOGGER.error(error)
        #   err_resp = Response.new(data)
        #   err_resp.errors << error
        #   err_resp
        # end
      end
    end

  end    
end
