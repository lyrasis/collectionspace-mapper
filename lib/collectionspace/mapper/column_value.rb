# frozen_string_literal: true

module CollectionSpace
  module Mapper

    # represents a row of data from a CSV.
    class ColumnValue
      attr_reader :column, :value, :mapping
      def initialize(column, value, recmapper)
        @column = column.downcase
        @value = value
        @mapping = recmapper.mappings.lookup(@column)
      end
    end
  end
end
