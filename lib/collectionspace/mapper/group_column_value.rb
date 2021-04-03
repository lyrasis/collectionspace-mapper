# frozen_string_literal: true

require_relative 'column_value'

module CollectionSpace
  module Mapper

    # a column value destined for a field in a repeating field group
    class GroupColumnValue < ColumnValue
      def split
        @value.split(@recmapper.batchconfig.delimiter).map(&:strip)
      end
    end
  end
end
