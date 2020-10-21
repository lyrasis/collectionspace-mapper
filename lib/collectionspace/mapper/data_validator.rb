# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class RequiredField
      def initialize(fieldname, datacolumns)
        @field = fieldname.downcase
        @columns = datacolumns.map(&:downcase)
      end

      def present_in?(data)
        present = data.keys.map(&:downcase) & @columns
        present.empty? ? false : true
      end

      def populated_in?(data)
        data = data.transform_keys(&:downcase)
        values = @columns.map{ |column| data[column] }.reject(&:blank?)
        values.empty? ? false : true
      end
    end

    class SingleColumnRequiredField < RequiredField
      def initialize(fieldname, datacolumns)
        super
      end

      def present_in?(data)
        super
      end

      def missing_message
        "required field missing: #{@columns[0]} must be present"
      end

      def empty_message
        "required field empty: #{@columns[0]} must be populated"
      end
    end

    class MultiColumnRequiredField < RequiredField
      def initialize(fieldname, datacolumns)
        super
      end

      def present_in?(data)
        super
      end

      def missing_message
        "required field missing: #{fieldname}. At least one of the following fields must be present: #{@columns.join(', ')}"
      end

      def empty_message
        "required field empty: #{fieldname}. At least one of the following fields must be populated: #{@columns.join(', ')}"
      end
    end

    class DataValidator
      attr_reader :mapper, :cache, :required_fields
      def initialize(record_mapper, cache)
        @mapper = record_mapper
        @cache = cache
        @required_mappings = @mapper[:mappings].select{ |mapping| mapping[:required] == 'y' }
        @required_fields = get_required_fields
        @id_field = @mapper[:config][:identifier_field].downcase
      end

      def validate(data)
        response = CollectionSpace::Mapper::setup_data(data)
        if response.valid?
          data = data.transform_keys(&:downcase)
          res = check_required_fields(data) unless @required_fields.empty?
          response.errors << res
          response.errors = response.errors.flatten.compact
          response
        else
          response
        end
      end
      
      private

      def get_required_fields
        h = {}
        @required_mappings.each do |m|
          field = m[:fieldname].downcase
          column = m[:datacolumn].downcase
          h.key?(field) ? h[field] << column : h[field] = [column]
        end
        #binding.pry
        
      end

      def check_required_fields(data)
        errs = []
        @required_fields.each do |field, columns|
          if columns.length == 1
            
          else
          end
        end
        
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

