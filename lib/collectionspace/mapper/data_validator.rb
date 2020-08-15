# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataValidator
      ::DataValidator = CollectionSpace::Mapper::DataValidator
      attr_reader :mapper, :cache, :required_fields
      def initialize(record_mapper, cache)
        @mapper = record_mapper
        @cache = cache
        @required_fields = @mapper[:mappings].select{ |mapping| mapping[:required] == 'y' }
          .map{ |mapping| mapping[:datacolumn].downcase }
      end

      def validate(data_hash, response = nil)
        response = response.nil? ? Response.new(data_hash) : response
        data = data_hash.transform_keys(&:downcase)
        res = check_required_fields(data)
        response.errors << res
        response.errors = response.errors.flatten.compact
        response
      end
      
    private

    def check_required_fields(data)
      errs = []
      @required_fields.each do |f|
        val = data.dig(f)
        err = nil
        if val.nil?
          err = {level: :error,
                 field: f,
                 type: 'required field missing',
                 message: "required field #{f} is missing"
                }
        elsif val.empty?
          err = {level: :error,
                 field: f,
                 type: 'required field empty',
                 message: "required field #{f} is empty"
                }
        else
        end
        errs << err
        end
        errs
      end
    end
  end
end
 
