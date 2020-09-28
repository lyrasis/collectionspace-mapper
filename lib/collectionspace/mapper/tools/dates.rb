# frozen_string_literal: true

require 'chronic'
require 'facets/date'
require 'facets/time'

module CollectionSpace
  module Mapper
    module Tools
      module Dates
        extend self

        class CspaceDate
          attr_reader :date_string, :client, :cache, :config, :timestamp, :mappable, :stamp

          def initialize(date_string, client, cache, config)
            @date_string = date_string
            @client = client
            @cache = cache
            @config = config
            @mappable = {}

            if @config[:date_format] == 'day month year'
              @timestamp = Chronic.parse(@date_string, endian_precedence: :little)
            else
              @timestamp = Chronic.parse(@date_string)
            end

            @timestamp ? create_mappable : try_services_query

            stamp = @mappable.fetch('dateEarliestScalarValue', nil)
            @stamp = stamp.blank? ? @date_string : stamp
          end
          
          def create_mappable
            date = @timestamp.to_date
            next_day = date + 1
            timestamp_suffix = 'T00:00:00.000Z'
            ce = "urn:cspace:#{@cache.domain}:vocabularies:name(dateera):item:name(ce)'CE'"
            
            @mappable['dateDisplayDate'] = @date_string
            @mappable['dateEarliestSingleYear'] = date.year.to_s
            @mappable['dateEarliestSingleMonth'] = date.month.to_s
            @mappable['dateEarliestSingleDay'] = date.day.to_s
            @mappable['dateEarliestSingleEra'] = ce
            @mappable['dateEarliestScalarValue'] = "#{date.stamp(:db)}#{timestamp_suffix}"
            @mappable['dateLatestScalarValue'] = "#{next_day.stamp(:db)}#{timestamp_suffix}"
            @mappable['scalarValuesComputed'] = 'true'
          end

          def try_services_query
            sdquery = "structureddates?displayDate=#{date_string}"
            response = client.get(sdquery)
            if response.status_code == 200
              @mappable = response.result['structureddate_common']
            else
              @mappable = { 'dateDisplayDate' => date_string,
                                'scalarValuesComputed' => 'false'
                               }
            end
          end

          def map(doc, parentnode, groupname)
            @parser_result.each do |datefield, value|
              value = DateTime.parse(value).iso8601(3).sub('+00:00', "Z") if datefield['ScalarValue']
            end
          end
        end
      end
    end
  end
end
