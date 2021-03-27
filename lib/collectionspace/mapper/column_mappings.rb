# frozen_string_literal: true

require 'forwardable'

module CollectionSpace
  module Mapper
    # aggregate class to work with all of a RecordMapper's ColumnMapping objects in an
    #   Array-ish fashion
    class ColumnMappings
      extend Forwardable

      def_delegators :@all, :<<, :each, :reject!, :select, :map
      def initialize(mappings_array)
        @all = []
        mappings_array.each{ |mapping| @all << symbolize(mapping) }
      end

      def known_columns
        @all.map do |mapping|
          mapping[:datacolumn].downcase
        end
      end

      private

      def symbolize(mapping)
        mapping.transform_keys!(&:to_sym)

        transforms = mapping[:transforms]
        return mapping if transforms.blank?
        
        transforms.transform_keys!(&:to_sym)
        mapping
      end
    end
  end
end
