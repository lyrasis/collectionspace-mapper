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
        @id_field = @mapper[:config][:identifier_field].downcase
      end

      def validate(data)
        response = Mapper::setup_data(data)
        if response.valid?
          data = data.transform_keys(&:downcase)
          res = check_required_fields(data) unless @required_fields.empty?
          res = check_id_field(data) if @required_fields.empty?
          response.errors << res
          response.errors = response.errors.flatten.compact
          response
        else
          response
        end
      end
      
      private

      def check_id_field(data)
        errs = []
        val = data.dig(@id_field)
        if val.nil?
          errs << {level: :error,
                 field: @id_field,
                 type: 'record id field missing',
                 message: "record id field #{@id_field} is missing"
                  }
        elsif val.empty?
          errs << {level: :error,
                   field: @id_field,
                   type: 'record id field empty',
                   message: "record id field #{@id_field} is empty"
                  }
        end
        errs
      end

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
 
