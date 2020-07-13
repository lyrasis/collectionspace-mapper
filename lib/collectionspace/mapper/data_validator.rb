# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataValidator
      ::DataValidator = CollectionSpace::Mapper::DataValidator
      attr_reader :mapper, :cache, :required_fields
      def initialize(record_mapper:, cache:)
        @mapper = record_mapper
        @cache = cache
        @required_fields = @mapper[:mappings].select{ |mapping| mapping[:required] == 'y' }
          .map{ |mapping| mapping[:datacolumn].downcase }
      end

    def validate(record_hash)
      report = []
      data = record_hash.transform_keys(&:downcase)
      res = check_required_fields(data)
      report << res
      report.flatten.compact
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
                 type: 'required fields',
                 message: 'required field missing'
                }
        elsif val.empty?
          err = {level: :error,
                 field: f,
                 type: 'required fields',
                 message: 'required field is empty'
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
 
