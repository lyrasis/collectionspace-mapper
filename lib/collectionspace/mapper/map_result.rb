# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class MapResult
      ::MapResult = CollectionSpace::Mapper::MapResult
      attr_reader :orig_data
      attr_accessor :split_data, :merged_data, :transformed_data, :combined_data, :doc, :warnings
      def initialize(data_hash:)
        @orig_data = data_hash
        @merged_data = {}
        @split_data = {}
        @transformed_data = {}
        @combined_data = {}
        @doc = nil
        @warnings = []
      end
    end
  end
end

