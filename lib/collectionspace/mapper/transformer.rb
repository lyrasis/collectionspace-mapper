# frozen_string_literal: true

module CollectionSpace
  module Mapper

    # parent class of the data value Transformer class hierarchy
    class Transformer
      attr_reader :order
      
      PRECEDENCE = [FindReplaceTransformer,
                    DowncaseTransformer,
                    BooleanTransformer,
                    DateStampTransformer,
                    StructuredDateTransformer,
                    BehrensmeyerTransformer,
                    VocabularyTransformer,
                    AuthorityTransformer,
                    Transformer]
      
      def initialize(transform: {})
        @order = PRECEDENCE.find_index(self.class.name)
      end

      private

      def self.create(type:, transform: {})
        case type.to_sym
        when :authority
          AuthorityTransformer.new(transform: transform)
        when :vocabulary
          VocabularyTransformer.new(transform: transform)
        when :special
          transform.map{ |xformname| special_transformers(xformname) }
        when :replacements
          transform.map{ |iteration| FindReplaceTransformer.new(transform: iteration) }
        end
      end

      def special_transformers(xformname)
        case xformname
        when 'boolean'
          BooleanTransformer.new
        when 'behrensmeyer_translate'
          BehrensmeyerTransformer.new
        when 'downcase_value'
          DowncaseTransformer.new
        end
      end
    end
  end
end
