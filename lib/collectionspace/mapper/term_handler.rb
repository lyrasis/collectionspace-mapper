# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class TermHandler
      attr_reader :result, :terms
      def initialize(mapping, data, cache)
        @mapping = mapping
        @column = mapping[:datacolumn]
        @field = mapping[:fieldname]
        @data = data
        @cache = cache
        @source_type = @mapping[:source_type].to_sym
        @terms = []
        case @source_type
        when :authority
          authconfig = @mapping[:transforms][:authority]
          @type = authconfig[0]
          @subtype = authconfig[1]
        when :vocabulary
          @type = 'vocabularies'
          @subtype = @mapping[:transforms][:vocabulary]
        end
        handle_terms
      end

      private

      def handle_terms
        if @data.first.is_a?(String)
          @result = @data.map{ |val| handle_term(val) }
        else
          @result = @data.map{ |arr| arr.map{ |val| handle_term(val)} }
        end
      end

      def handle_term(val)
        return '' if val.blank?
        
        refname_urn = @cache.get(@type, @subtype, val)
        
        term_report = {
          category: @source_type,
          field: @column,
          }
        if refname_urn
          refname_obj = CollectionSpace::Mapper::Tools::RefName.new(urn: refname_urn)
          @terms << term_report.merge({ found: true, refname: refname_obj })
          refname_urn
        else
          refname_obj = CollectionSpace::Mapper::Tools::RefName.new(
            source_type: @source_type,
            type: @type,
            subtype: @subtype,
            term: val,
            cache: @cache)
          @terms << term_report.merge({ found: false, refname: refname_obj })
          refname_obj.urn
        end
      end
    end
  end
end

