# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataQualityChecker
      attr_reader :mapping, :data, :warnings, :terms
      def initialize(mapping, data)
        @mapping = mapping
        @column = mapping[:datacolumn]
        @field = mapping[:fieldname]
        @data = data
        @warnings = []
        @terms = []
        @source_type = @mapping[:source_type]

        case @source_type
        when 'authority'
          authconfig = @mapping[:transforms][:authority]
          @type = authconfig[0]
          @subtype = authconfig[1]
          check_terms
        when 'vocabulary'
          @type = 'vocabularies'
          @subtype = @mapping[:transforms][:vocabulary]
          check_terms
        when 'optionlist'
          check_opt_list_vals
        end
      end

      private

      def check_terms
        if @data.first.is_a?(String)
          @data.each{ |val| check_term(val) unless val.blank? }
        else
          @data.each{ |arr| arr.each{ |val| check_term(val) unless val.blank? } }
        end
      end

      def check_term(val)
        term_report = {
          category: @source_type.to_sym,
          field: @column,
          type: @type,
          subtype: @subtype,
          value: val
          }
        if val.start_with?('urn:cspace')
          @terms << term_report.merge({ found: true })
        else
          @terms << term_report.merge({ found: false })
        end
      end

      def check_opt_list_vals
        @opts = @mapping[:opt_list_values]
        if @data.first.is_a?(String)
          @data.each{ |val| check_opt_list_val(val) unless val.blank? }
        else
          @data.each{ |arr| arr.each{ |val| check_opt_list_val(val) unless val.blank? } }
        end
      end

      def check_opt_list_val(val)
        return if @opts.include?(val)
        @warnings << {
          category: :unknown_option_list_value,
          field: @column,
          type: 'option list value',
          subtype: '',
          value: val,
          message: "Unknown value in option list `#{@column}` column" 
        }
      end
    end
  end
end

