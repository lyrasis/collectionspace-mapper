# frozen_string_literal: true

require 'forwardable'

module CollectionSpace
  module Mapper
    # aggregate class to work with all of a RecordMapper's ColumnMapping objects in an
    #   Array-ish fashion
    class ColumnMappings
      extend Forwardable

      attr_reader :config
      def_delegators :@all, :each, :length, :map, :reject!, :select
      
      def initialize(opts = {})
        @config = opts[:mapperconfig]
        self.service_type = opts[:service_type]
        @all = []
        @lookup = {}
        opts[:mappings].each{ |mapping_hash| add_mapping(mapping_hash) }
        special_mappings.each{ |mapping| add_mapping(mapping) }
      end

      def <<(mapping_hash)
        add_mapping(mapping_hash)
      end

      def known_columns
        @all.map(&:datacolumn)
      end

      def lookup(columnname)
        @lookup[columnname.downcase]
      end

      def required_columns
        @all.select(&:required?)
      end

      private

      def service_type=(mawdule)
        return unless mawdule
        extend(mawdule)
      end

      def add_mapping(mapping_hash)
        mapobj = CS::Mapper::ColumnMapping.new(mapping_hash)
        @all << mapobj
        @lookup[mapobj.datacolumn] = mapobj
      end

      def special_mappings
        []
      end
    end
  end
end
