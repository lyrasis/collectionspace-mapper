# frozen_string_literal: true

require 'collectionspace/mapper/tools/symbolizable'

module CollectionSpace
  module Mapper

    # represents a JSON RecordMapper containing the config, field mappings, and template
    #  for transforming a hash of data into CollectionSpace XML

    # :reek:Attribute - when I get rid of xphash, this will go away
    class RecordMapper
      include Tools::Symbolizable
      
      attr_reader :config, :mappings, :docstructure
      attr_accessor :xpath
      
      def initialize(json)
        @xpath = {}
        convert(json)
      end

      def authority?
        service_type == 'authority'
      end

      def object_hierarchy?
        record_type == 'objecthierarchy'
      end

      def authority_hierarchy?
        record_type == 'authorityhierarchy'
      end

      def non_hierarchical_relationship?
        record_type == 'nonhierarchicalrelationship'
      end

      def relationship?
        service_type == 'relation'
      end
      
      def record_type
        @config.recordtype
      end

      def service_type
        @config.service_type
      end
      
      private

      def convert(json)
        hash = symbolize(json)
        @config = CS::Mapper::RecordMapperConfig.new(hash[:config])
        @docstructure = hash[:docstructure]
        @mappings = CS::Mapper::ColumnMappings.new(hash[:mappings])
      end
    end
  end
end
