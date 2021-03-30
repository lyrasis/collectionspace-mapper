# frozen_string_literal: true

require 'forwardable'

module CollectionSpace
  module Mapper
    # aggregate class to work with all of a RecordMapper's ColumnMapping objects in an
    #   Array-ish fashion
    class ColumnMappings
      extend Forwardable

      def_delegators :@all, :each, :length, :map, :reject!, :select
      def initialize(mappings_array)
        @all = []
        @lookup = {}
        mappings_array.each{ |mapping_hash| add_mapping(mapping_hash) }
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

      def add_mapping(mapping_hash)
        mapobj = CS::Mapper::ColumnMapping.new(mapping_hash)
        @all << mapobj
        @lookup[mapobj.datacolumn] = mapobj
      end
    end
  end
end
