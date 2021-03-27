# frozen_string_literal: true

module CollectionSpace
  module Mapper

    # represents a JSON RecordMapper containing the config, field mappings, and template
    #  for transforming a hash of data into CollectionSpace XML
    class RecordMapper
      attr_reader :config, :mappings, :docstructure
      attr_accessor :xpath
      
      def initialize(json)
        @xpath = {}
        convert(json)
      end
      
      private

      def convert(json)
        hash = json.transform_keys{ |key| key.to_sym }
        @config = hash[:config].transform_keys{ |key| key.to_sym }
        @docstructure = hash[:docstructure]
        @mappings = CollectionSpace::Mapper::ColumnMappings.new(hash[:mappings])
      end
    end
  end
end
