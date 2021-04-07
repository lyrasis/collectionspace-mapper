# frozen_string_literal: true

require_relative 'transformer'

module CollectionSpace
  module Mapper

    # carries out a find/replace operation on a given value
    class FindReplaceTransformer < Transformer
      def initialize(transform:)
        super
      end
      
      def transform(value)
      end
    end
  end
end
