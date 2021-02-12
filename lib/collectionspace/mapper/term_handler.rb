# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class TermHandler
      attr_reader :result, :terms, :warnings, :errors,
        :column, :source_type, :type, :subtype
      attr_accessor :value
      def initialize(mapping:, data:, client:, cache:, config:)
        @mapping = mapping
        @column = mapping[:datacolumn]
        @field = mapping[:fieldname]
        @data = data
        @cache = cache
        @client = client
        @config = config
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
        @warnings = []
        @errors = []
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
        @value = val
        
        return '' if val.blank?
        added = false
        
        term_report = {
          category: source_type,
          field: column
        }

        if in_cache?(val)
          refname_urn = cached_term(val)
          if refname_urn
            add_found_term(refname_urn, term_report)
            added = true
          end
        else # not in cache
          if @config[:check_terms]
            refname_urn = searched_term(val)
            if refname_urn
              add_found_term(refname_urn, term_report)
              added = true
            end
          end
        end

        unless added
          refname_obj = CollectionSpace::Mapper::Tools::RefName.new(
            source_type: source_type,
            type: type,
            subtype: subtype,
            term: val,
            cache: @cache)
          @terms << term_report.merge({ found: false, refname: refname_obj })
          @cache.put(type, subtype, val, refname_obj.urn)
          refname_urn = refname_obj.urn
        end
        refname_urn
      end

      def in_cache?(val)
        @cache.exists?(type, subtype, val)
      end

      def cached_term(val)
        @cache.get(type, subtype, val, search: false)
      end

      def searched_term(val)
        begin
          response = @client.find(
            type: type,
            subtype: subtype,
            value: val,
            field: search_field
          )
        rescue StandardError => e
          puts e.message
        else
          response_term_refname(response)
        end
      end

      def response_term_refname(response)
        term_ct = response.parsed.dig('abstract_common_list', 'totalItems')
        return nil if term_ct.nil?

        if term_ct.to_i == 1
          refname = response.parsed.dig('abstract_common_list', 'list_item', 'refName')
        elsif term_ct.to_i > 1
          rec = response.parsed.dig('abstract_common_list', 'list_item')[0]
          using_uri = "#{@client.config.base_uri}#{rec['uri']}"
          refname = rec['refName']
          warnings << {
            category: :multiple_records_found_for_term,
            field: column,
            type: type,
            subtype: subtype,
            value: value,
            message: "#{term_ct} records found. Using #{using_uri}"
          }
        end
        refname
      end
      
      def search_field
        begin
          field = CollectionSpace::Service.get(type: type)[:term]
        rescue StandardError => e
          puts e.message
        else
          field
        end
      end
      
      def add_found_term(refname_urn, term_report)
        refname_obj = CollectionSpace::Mapper::Tools::RefName.new(urn: refname_urn)
        found = @config[:check_terms] ? true : false 
        @terms << term_report.merge({ found: found, refname: refname_obj })
      end
    end
  end
end

