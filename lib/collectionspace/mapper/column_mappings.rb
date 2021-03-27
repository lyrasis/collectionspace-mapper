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
        mappings_array.each{ |mapping| @all << CollectionSpace::Mapper::ColumnMapping.new(mapping) }
      end

      def <<(mapping_hash)
        @all << CollectionSpace::Mapper::ColumnMapping.new(mapping_hash)
      end

      def known_columns
        @all.map(&:datacolumn)
      end

      def required
        @all.select(&:required?)
      end
    end
  end
end
