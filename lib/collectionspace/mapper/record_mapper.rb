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
        h = json.transform_keys{ |k| k.to_sym }
        @config = h[:config].transform_keys{ |key| key.to_sym }
        @docstructure = h[:docstructure]
        h[:mappings].each do |m|
          m.transform_keys!(&:to_sym)
          if m[:transforms] && !m[:transforms].empty?
            m[:transforms].transform_keys!(&:to_sym)
          end
        end
        @mappings = h[:mappings]
      end
    end
  end
end
