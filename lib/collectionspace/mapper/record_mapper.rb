# frozen_string_literal: true

require 'collectionspace/mapper/tools/symbolizable'

module CollectionSpace
  module Mapper

    # Represents a JSON RecordMapper containing the config, field mappings, and template
    #  for transforming a hash of data into CollectionSpace XML
    # The RecordMapper bundles up all the info needed by various other classes in order
    #  to transform and map incoming data into CollectionSpace XML, so it gets passed
    #  around to everything

    # :reek:Attribute - when I get rid of xphash, this will go away
    # :reek:InstanceVariableAssumption - instance variable gets set by convert
    class RecordMapper
      include Tools::Symbolizable
      
      attr_reader :batchconfig, :config, :mappings, :docstructure
      attr_accessor :xpath
      
      def initialize(json, batchconfig = nil)
        @batchconfig = batchconfig
        jhash = json.is_a?(Hash) ? json : JSON.parse(json)
        @xpath = {}
        convert(jhash)
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
