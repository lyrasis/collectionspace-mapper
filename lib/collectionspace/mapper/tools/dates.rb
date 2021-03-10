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

            if parsing_warnings?
              parsed_date.warnings.each do |warning|
                warnings << {
                  category: :date_parser_warning,
                  field: nil,
                  value: date_string,
                  message: warning
                }
              end
            end

            if parsing_errors?
              warnings << {
                category: :date_cannot_be_processed,
                field: nil,
                value: date_string,
                message: "\"#{date_string}\" will be passed through as dateDisplayDate with no scalar values"
              }
              passthrough_display_date
              return
            end

            if no_dates?
              passthrough_display_date

              set_certainty('no date')
              return
            end

            process_dates

            @stamp = mappable['dateEarliestScalarValue'] ? mappable['dateEarliestScalarValue'] : mappable['dateLatestScalarValue']
          end

          def warnings?
            !@warnings.empty?
          end
          
          private

          def process_dates
            if parsed_date.dates.length > 1
              warnings << {
                category: :date_multiple_returned,
                field: nil,
                value: date_string,
                message: "\"#{date_string}\" is parsed into #{parsed_date.dates.length} parsed dates. Only the first will be processed."
              }
            end

            thedate = parsed_date.dates[0]

            set_display_date
            set_scalar_values(thedate)
            set_certainty_values(thedate.certainty)
          end

          def set_certainty_values(certainty)
            return if certainty.empty?

            certainty.sort!
            
            lookup = {
              %i[approximate] => 'approximate',
              %i[inferred] => 'supplied or inferred',
              %i[uncertain] => 'possibly',
              %i[approximate inferred uncertain] => 'approximate, possibly, and supplied',
              %i[approximate inferred] => 'approximate and supplied',
              %i[approximate uncertain] => 'approximate and possibly',
              %i[inferred uncertain] => 'possibly and supplied'
            }

            term = lookup[certainty]

            if term.nil?
              warnings << {
                category: :date_certainty_value_combination,
                field: nil,
                value: date_string,
                message: "Parsing \"#{date_string}\" results in this combination of certainty values, which cannot currently be handled by the mapper: #{certainty.join(', ')}"
              }
              return
            end

            set_certainty(term)
          end
          
          def set_certainty(term)
            refname = get_vocabulary_term(vocab: 'datecertainty', term: term)
            if refname.nil?
              warnings << {
                category: :date_certainty_vocab_term_missing,
                field: nil,
                value: term,
                message: "datecertainty vocabulary does not include: \"#{term}\""
              }
              return
            end
            
            mappable['dateEarliestSingleCertainty'] = refname
            return if term == 'no date'
            mappable['dateLatestCertainty'] = refname unless mappable['dateLatestScalarValue'].nil?
          end
          
          def set_earliest_scalar_values(pdate)
            return if pdate.nil?
            date = Date.parse(pdate)
            mappable['dateEarliestSingleYear'] = date.year.to_s
            mappable['dateEarliestSingleMonth'] = date.month.to_s
            mappable['dateEarliestSingleDay'] = date.day.to_s
            mappable['dateEarliestSingleEra'] = @ce
            mappable['dateEarliestScalarValue'] = "#{date.iso8601}#{TIMESTAMP_SUFFIX}"
          end

          def set_latest_scalar_values(pdate)
            return if pdate.nil?
            date = Date.parse(pdate)
            mappable['dateLatestYear'] = date.year.to_s
            mappable['dateLatestMonth'] = date.month.to_s
            mappable['dateLatestDay'] = date.day.to_s
            mappable['dateLatestEra'] = @ce
            mappable['dateLatestScalarValue'] = "#{date.iso8601}#{TIMESTAMP_SUFFIX}"
          end

          def set_scalar_values(pdate)
            set_earliest_scalar_values(pdate.date_start_full)
            set_latest_scalar_values(pdate.date_end_full) unless pdate.date_end_full == pdate.date_start_full

            unless mappable.key?('dateLatestScalarValue')
              mappable['dateLatestScalarValue'] = mappable['dateEarliestScalarValue']
            end
            
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
