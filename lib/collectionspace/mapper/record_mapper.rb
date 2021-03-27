# frozen_string_literal: true

module CollectionSpace
  module Mapper

    # represents a JSON RecordMapper containing the config, field mappings, and template
    #  for transforming a hash of data into CollectionSpace XML

    # :reek:Attribute - when I get rid of xphash, this will go away
    class RecordMapper
      include Tools::Symbolizable
      
      attr_reader :config, :mappings, :docstructure
      attr_accessor :xpath
      
      def initialize(json)
        @xpath = {}
        convert(json)
      end
      
      private

      def convert(json)
        hash = symbolize(json)
        @config = symbolize(hash[:config])
        @docstructure = hash[:docstructure]
        @mappings = CollectionSpace::Mapper::ColumnMappings.new(hash[:mappings])
      end
    end
  end
end
