# frozen_string_literal: true

module CollectionSpace
  module Mapper

    # aggregate representation of transformers associated with a ColumnMapping (queue)
    # Performs a factory function by creating the appropriate individual Transformers for a given
    #   ColumnMapping based on data_type
    # Also has the logic for how to keep Transformers in the proper order in the queue. Batch
    #   config-specified transformers should be first, followed by anything else, followed finally
    #   by AuthorityTermTransformer or VocabularyTermTransformer
    class Transformers
      def initialize(colmapping:, transforms:)
        @colmapping = colmapping
        @transforms = transforms
        @queue = []
        populate_queue
      end

      
      private

      def populate_queue
        data_type_transforms
        return @queue if @transforms.empty?

        @queue << @transforms.map{ |type, transform| Transformer.class.create(type: type, transform: transform) }
        @queue.flatten
      end

      def data_type_transforms
        @queue << DateStampTransformer.new if @colmapping.datatype == 'date'
        @queue << StructuredDateTransformer.new if @colmapping.datatype == 'structured date group'
      end      
    end
  end
end
