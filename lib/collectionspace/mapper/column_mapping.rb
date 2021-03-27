# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # mapping instructions for an individual data column
    class ColumnMapping
      attr_reader :data_type, :in_repeating_group, :namespace, :opt_list_values,
        :repeats, :source_type, :transforms
      def initialize(mapping_hash)
        mapping_hash.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
        symbolize_transforms
      end

      def datacolumn
        @datacolumn.downcase
      end

      def fieldname
        @fieldname
      end

      def fullpath
        @fullpath ||= [@namespace, @xpath].flatten.join('/')
      end

      def required?
        @required == 'y'
      end

      def xml_fieldname
        @fieldname
      end

      def [](attribute)
        instance_variable_get("@#{attribute}")
      end

      def []=(attribute, value)
        instance_variable_set("@#{attribute}", value)
      end
      
      private

      def symbolize_transforms
        return if @transforms.blank?
        
        @transforms.transform_keys!(&:to_sym)
      end
    end
  end
end
