# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataQualityChecker
      ::DataQualityChecker = CollectionSpace::Mapper::DataQualityChecker
      attr_reader :mapping, :data, :warnings, :missing_terms
      def initialize(mapping, data)
        @mapping = mapping
        @data = data
        @warnings = []
        @missing_terms = []
        @source_type = @mapping[:source_type]

        case @source_type
        when 'authority'
          authconfig = @mapping[:transforms][:authority]
          @category = :authority
          @type = authconfig[0]
          @subtype = authconfig[1]
          check_terms
        when 'vocabulary'
          @category = :vocabulary
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
          @data.each{ |val| check_term(val) }
        else
          @data.each{ |arr| arr.each{ |val| check_term(val) } }
        end
      end

      def check_term(val)
        return if val.start_with?('urn:cspace')
        @missing_terms << {
          category: @category,
          field: @mapping[:datacolumn],
          type: @type,
          subtype: @subtype,
          value: val
        }
      end

      def check_opt_list_vals
        @opts = @mapping[:opt_list_values]
        if @data.first.is_a?(String)
          @data.each{ |val| check_opt_list_val(val) }
        else
          @data.each{ |arr| arr.each{ |val| check_opt_list_val(val) } }
        end
      end

      def check_opt_list_val(val)
        return if @opts.include?(val)
        @warnings << {
          level: :warning,
          field: @mapping[:fieldname],
          type: 'option list',
          message: "#{val} is not an allowed value for this field"
        }
      end
    end
  end
end

