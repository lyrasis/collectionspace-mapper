# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class MapResult
      ::MapResult = CollectionSpace::Mapper::MapResult
      attr_reader :orig_data
      attr_accessor :split_data, :transformed_data, :doc, :warnings, :missing_terms
      def initialize(data_hash:)
        @orig_data = data_hash
        @split_data = {}
        @transformed_data = {}
        @warnings = []
        @missing_terms = []
      end

      private

    end
  end
end

