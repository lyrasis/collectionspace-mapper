# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class NonHierarchicalRelationshipPrepper < CollectionSpace::Mapper::DataPrepper
      include CollectionSpace::Mapper::TermSearchable
      attr_reader :errors, :warnings, :responses
      
      def initialize(data, handler)
        super
        @cache = @handler.csidcache
        @types = [@data['item1_type'], @data['item2_type']]
        @errors = []
        @warnings = []
        @responses = []
      end
      
      def prep
        @response.identifier = "#{stringify_item(1)} -> #{stringify_item(2)}"
        split_data
        transform_terms
        combine_data_fields
        @responses << @response
        flip_response
        @responses
      end

      private

      def stringify_item(i)
        id = "item#{i}_id"
        type = "item#{i}_type"
        thisid = @data[id]
        thistype = @data[type]
        "#{thisid} (#{thistype})"
      end


      def flip_response
        resp2 = @response.dup
        resp2.identifier = "#{stringify_item(2)} -> #{stringify_item(1)}"
        resp2.combined_data = {'relations_common'=>{}}
        origrel = @response.combined_data['relations_common']['relationshipType']
        origsub = @response.combined_data['relations_common']['subjectCsid']
        origobj = @response.combined_data['relations_common']['objectCsid']
        resp2.combined_data['relations_common']['relationshipType'] = origrel
        resp2.combined_data['relations_common']['subjectCsid'] = origobj
        resp2.combined_data['relations_common']['objectCsid'] = origsub
        @responses << resp2
      end

      def process_xpaths
        clear_unmapped_mappings
        @handler.mapper[:xpath] = @handler.xpath_hash
        super
      end
      

      # these mappings were needed to get data in via template for processing, but
      #  do not actually get used to produce XML
      def clear_unmapped_mappings
        to_clear = %w[subjectType objectType]
        @handler.mapper[:mappings].reject!{ |m| to_clear.include?(m[:fieldname]) }
      end

      def transform_terms
        %w[item1_id item2_id].each_with_index do |field, i|
          transformed = @response.split_data[field].map{ |id| obj_csid(id, @types[i]) }
          @response.transformed_data[field] = transformed
        end

        @response.split_data.each do |field, value|
          unless @response.transformed_data.key?(field)
            @response.transformed_data[field] = value
          end
        end
      end

      def type
        @type
      end

      def subtype
        @subtype
      end
    end
  end
end
