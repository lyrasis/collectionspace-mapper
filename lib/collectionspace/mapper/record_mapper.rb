# frozen_string_literal: true

require 'collectionspace/mapper/tools/symbolizable'

module CollectionSpace
  module Mapper

    # Represents a JSON RecordMapper containing the config, field mappings, and template
    #  for transforming a hash of data into CollectionSpace XML
    # The RecordMapper bundles up all the info needed by various other classes in order
    #  to transform and map incoming data into CollectionSpace XML, so it gets passed
    #  around to everything as a kind of mondo-configuration-object, which is probably
    #  terrible OOD but better than what I had before? 

    # :reek:Attribute - when I get rid of xphash, this will go away
    # :reek:InstanceVariableAssumption - instance variable gets set by convert
    class RecordMapper
      include Tools::Symbolizable
      
      attr_reader :batchconfig, :config, :mappings, :xml_template
      attr_accessor :xpath
      
      def initialize(json, batchconfig = {})
        jhash = json.is_a?(Hash) ? json : JSON.parse(json)
        convert(jhash)
        @batchconfig = CS::Mapper::Config.new(config: batchconfig, record_type: record_type_extension)
        @xpath = {}
      end

      def authority?
        service_type == 'authority'
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
        @xml_template = CS::Mapper::XmlTemplate.new(hash[:docstructure])
        @mappings = CS::Mapper::ColumnMappings.new(hash[:mappings])
      end

      def record_type_extension
        case record_type
        when 'objecthierarchy'
          CS::Mapper::ObjectHierarchy
        when 'authorityhierarchy'
          CS::Mapper::AuthorityHierarchy
        when 'nonhierarchicalrelationship'
          CS::Mapper::NonHierarchicalRelationship
        end
      end
    end
  end
end
