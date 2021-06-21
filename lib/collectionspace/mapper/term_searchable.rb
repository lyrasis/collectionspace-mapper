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

      # the thing with downcasing and capitalizing is needed because the form
      # of certain vocabulary terms used across profiles is capitalized in
      # some profiles, all lowercase in others. Consistency is a dream...
      def get_vocabulary_term(vocab:, term:)
        result = @cache.get('vocabularies', vocab, term, search: true)
        return result unless result.nil?

        if has_caps?(term)
          @cache.get('vocabularies', vocab, term.downcase, search: true)
        else
          @cache.get('vocabularies', vocab, term.capitalize, search: true)
        end
        return result unless result.nil?

        result = search_vocabulary_term(vocab: vocab, term: term)
        return result unless result.nil?

        if has_caps?(term)
          search_vocabulary_term(vocab: vocab, term: term.downcase)
        else
          search_vocabulary_term(vocab: vocab, term: term.capitalize)
        end
      end

      def search_vocabulary_term(vocab:, term:)
        begin
          response = @client.find(
            type: 'vocabularies',
            subtype: vocab,
            value: term,
            field: 'displayName'
          )
        rescue StandardError => e
          puts e.message
        else
          response_term_refname(response)
        end
      end
      
      def has_caps?(string)
        string.match?(/[A-Z]/) ? true : false
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

      def obj_csid(objnum, type)
        csid = @cache.get(type, '', objnum)
        return csid unless csid.nil?

        response = @client.find(type: type, value: objnum)
        if response.result.success?
          result = response.parsed['abstract_common_list']
          term_ct = result['totalItems'].to_i
          case term_ct
          when 0
            errors << {
              category: :no_records_found_with_objnum,
              field: '',
              type: type,
              subtype: '',
              value: objnum,
              message: "#{term_ct} records found."
            }
            csid = nil
          when 1
            csid = result['list_item']['csid']
          else
            rec = result['list_item'][0]
            using_uri = "#{@client.config.base_uri}#{rec['uri']}"
            csid = rec['csid']
            warnings << {
              category: :multiple_records_found_with_objnum,
              field: '',
              type: type,
              subtype: '',
              value: objnum,
              message: "#{term_ct} records found. Using #{using_uri}"
            }
          end

          return csid if csid.nil?
          
          @cache.put(type, '', objnum, csid)
          return csid
        else
          errors << {
            category: :unsuccessful_csid_lookup_for_objnum,
            field: '',
            type: type,
            subtype: '',
            value: objnum,
            message: "Problem with search for #{objnum}."
          }
          return nil
        end
      end

      def term_csid(term)
        csid = cached_term(term)
        return csid unless csid.nil?

        field = CollectionSpace::Service.get(type: type)[:term]

        response = @client.find(type: type, subtype: subtype, field: field, value: term)
        if response.result.success?
          result = response.parsed['abstract_common_list']
          term_ct = result['totalItems'].to_i
          case term_ct
          when 0
            errors << {
              category: :no_records_found_for_term,
              field: '',
              type: type,
              subtype: subtype,
              value: term,
              message: "#{term_ct} records found."
            }
            csid = nil
          when 1
            csid = result['list_item']['csid']
          else
            rec = result['list_item'][0]
            using_uri = "#{@client.config.base_uri}#{rec['uri']}"
            csid = rec['csid']
            warnings << {
              category: :multiple_records_found_for_term,
              field: '',
              type: type,
              subtype: subtype,
              value: term,
              message: "#{term_ct} records found. Using #{using_uri}"
            }
          end

          return csid if csid.nil?
          
          @cache.put(type, subtype, term, csid)
          return csid
        else
          errors << {
            category: :unsuccessful_csid_lookup_for_term,
            field: '',
            type: type,
            subtype: subtype,
            value: term,
            message: "Problem with search for #{term}"
          }
          return nil
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
