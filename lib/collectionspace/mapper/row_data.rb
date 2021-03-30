# frozen_string_literal: true

module CollectionSpace
  module Mapper

    # represents a row of data from a CSV.
    class RowData
      attr_reader :columns
      def initialize(datahash, recmapper)
        @recmapper = recmapper
        @columns = []
        datahash.each{ |column, value| @columns << CS::Mapper::ColumnValue.new(column, value, @recmapper) }
      end
    end
  end
end
