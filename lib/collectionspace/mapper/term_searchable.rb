# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module TermSearchable
      def in_cache?(val)
        @cache.exists?(type, subtype, val)
      end

      def cached_term(val)
        @cache.get(type, subtype, val, search: false)
      end

      def get_vocabulary_term(vocab:, term:)
        @cache.get('vocabularies', vocab, term, search: true)
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
    end
  end
end
