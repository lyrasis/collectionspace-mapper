# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML document
    class RecordValidator
      ::RecordValidator = CollectionSpace::Mapper::RecordValidator
      attr_reader :mapper, :cache,
        :id_field, :required_fields,
        :errors, :warnings, :newterms
      def initialize(record_mapper:, cache:)
        @mapper = record_mapper
        @cache = cache
        @id_field = Mapper::CONFIG[:rec_id_field].downcase
        @errors = []
        @warnings = []
        @newterms = []

        @required_fields = @mapper[:mappings].select{ |mapping| mapping[:required] == 'y' }
          .map{ |mapping| mapping[:datacolumn].downcase }
      end

      def validate(data)
        data = data.transform_keys(&:downcase)

        check_required_fields(data)
      end
      
      private

      def check_required_fields(data)
        @required_fields.each do |f|
          val = data.dig(f)
#          binding.pry
          if val.nil?
          @errors << {data_id: data[@id_field],
                      field: f,
                      type: 'required fields',
                      message: 'required field missing'
                     }
          elsif val.empty?
            @errors << {data_id: data[@id_field],
                        field: f,
                        type: 'required fields',
                        message: 'required field is empty'
                       }
          end
        end
        
      end
    end
  end
end
 
