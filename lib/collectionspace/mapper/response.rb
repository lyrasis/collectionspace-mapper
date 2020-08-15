# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Response
      ::Response = CollectionSpace::Mapper::Response
      attr_reader :orig_data
      attr_accessor :split_data, :merged_data, :transformed_data, :combined_data, :doc, :errors, :warnings, :identifier
      def initialize(data_hash)
        @orig_data = data_hash
        @merged_data = {}
        @split_data = {}
        @transformed_data = {}
        @combined_data = {}
        @doc = nil
        @errors = []
        @warnings = []
        @identifier = ''
      end

      def valid?
        @errors.empty? ? true : false
      end
    end
  end
end

