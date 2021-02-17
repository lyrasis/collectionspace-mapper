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
          include TermSearchable
          TIMESTAMP_SUFFIX = 'T00:00:00.000Z'
          attr_reader :date_string,
            :parsed_date, :mappable, :warnings,
            :timestamp, :stamp

          def initialize(date_string:, client:, cache:, config:)
            @date_string = date_string
            @client = client
            @cache = cache
            @config = CollectionSpace::Mapper::Tools::Config.new(config).date_config
            
            @mappable = {}
            @warnings = []

            @ce = "urn:cspace:#{@client.domain}:vocabularies:name(dateera):item:name(ce)'CE'"
            @nodate = "urn:cspace:#{@client.domain}:vocabularies:name(datecertainty):item:name(nodate)'no date'"

            process
          end

          def process
            return if date_string == '%NULLVALUE%'
            
            @parsed_date = Emendate.parse(date_string, @config)

            if parsing_errors?
              warnings << "Date parsing warning: Cannot process date: #{date_string}. Passing it through as dateDisplayDate with no scalar values"
              passthrough_display_date
              return
            end

            if parsing_warnings?
              parsed_date.warnings.each do |warning|
                warnings << "Date parsing warning: #{warning}"
              end
            end

            if no_dates?
              nodate = get_vocabulary_term(vocab: 'datecertainty', term: 'no date')
              passthrough_display_date
              set_earliest_certainty(nodate) unless nodate.nil?
              return
            end

            process_dates
            @stamp = mappable['dateEarliestScalarValue']
          end

          def process_dates
            if parsed_date.dates.length > 1
              warnings << "Date parsing warning: Multiple parsed dates returned (#{parsed_date.dates.length}). Processing only the first"
            end

            thedate = parsed_date.dates[0]
            if thedate.date_start_full == thedate.date_end_full
              set_display_date
              set_single_scalar_values(thedate)
            else
              set_display_date
              set_scalar_values(thedate)
            end

            set_supplied if thedate.certainty.include?(:inferred)
            
          end

          def set_supplied
            supp = get_vocabulary_term(vocab: 'datecertainty', term: 'supplied or inferred')
            return if supp.nil?

            mappable['dateEarliestSingleCertainty'] = supp
            mappable['dateLatestCertainty'] = supp unless mappable['dateLatestScalarValue'].nil?
          end
          
          def set_single_scalar_values(pdate)
            date = Date.parse(pdate.date_start_full)
            
            mappable['dateEarliestSingleYear'] = date.year.to_s
            mappable['dateEarliestSingleMonth'] = date.month.to_s
            mappable['dateEarliestSingleDay'] = date.day.to_s
            mappable['dateEarliestSingleEra'] = @ce
            mappable['dateEarliestScalarValue'] = "#{date.iso8601}#{TIMESTAMP_SUFFIX}"
            mappable['dateLatestScalarValue'] = "#{date.iso8601}#{TIMESTAMP_SUFFIX}"
            mappable['scalarValuesComputed'] = 'true'

          end

          def set_scalar_values(pdate)
            s_date = Date.parse(pdate.date_start_full)
            e_date = Date.parse(pdate.date_end_full)
            
            mappable['dateEarliestSingleYear'] = s_date.year.to_s
            mappable['dateEarliestSingleMonth'] = s_date.month.to_s
            mappable['dateEarliestSingleDay'] = s_date.day.to_s
            mappable['dateEarliestSingleEra'] = @ce
            mappable['dateEarliestScalarValue'] = "#{s_date.iso8601}#{TIMESTAMP_SUFFIX}"

            mappable['dateLatestYear'] = e_date.year.to_s
            mappable['dateLatestMonth'] = e_date.month.to_s
            mappable['dateLatestDay'] = e_date.day.to_s
            mappable['dateLatestEra'] = @ce
            mappable['dateLatestScalarValue'] = "#{e_date.iso8601}#{TIMESTAMP_SUFFIX}"
            mappable['scalarValuesComputed'] = 'true'
          end
          
          def set_earliest_certainty(refname)
            mappable['dateEarliestSingleCertainty'] = refname
          end

          def set_latest_certainty(refname)
            mappable['dateLatestCertainty'] = refname
          end

          def set_both_certainty(refname)
            set_earliest_certainty(refname)
            set_latest_certainty(refname)
          end

          def passthrough_display_date
            @mappable = {"dateDisplayDate"=>date_string,
                         "scalarValuesComputed"=>"false"}
          end

          def set_display_date
            @mappable = {"dateDisplayDate"=>date_string}
          end

          def no_dates?
            parsed_date.dates.empty? ? true : false
          end
          
          def parsing_errors?
            parsed_date.errors.empty? ? false : true
          end

          def parsing_warnings?
            parsed_date.warnings.empty? ? false : true
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
