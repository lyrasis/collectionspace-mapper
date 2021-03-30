# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class Config
      class ConfigKeyMissingError < StandardError
        attr_reader :keys
        def initialize(message, keys)
          super(message)
          @keys = keys
        end
      end

      class ConfigResponseModeError < StandardError; end

      class UnhandledConfigFormatError < StandardError; end

      attr_reader :delimiter, :subgroup_delimiter, :response_mode, :force_defaults, :check_record_status,
                    :check_terms, :date_format, :two_digit_year_handling, :transforms, :default_values
      # todo: move default config in here
      include Tools::Symbolizable
      def initialize(config)
        if config.is_a?(String)
          set_instance_variables(JSON.parse(config))
        elsif config.is_a?(Hash)
          set_instance_variables(config)
        else
          raise UnhandledConfigFormatError
        end
        validate
      end

      def hash
        config = self.to_h
        config = symbolize(config)
        transforms = config[:transforms]
        return config unless transforms
        
        config[:transforms] = symbolize_transforms(transforms)
        config
      end

      private

      def to_h
        hash = {}
        instance_variables.each do |var|
          key = var.to_s.delete('@').to_sym
          hash[key] = instance_variable_get(var)
        end
        hash
      end

      def set_instance_variables(hash)
        hash.each{ |key, value| instance_variable_set("@#{key}", value) }
      end
      
      def validate
        begin
          has_required_attributes
        rescue ConfigKeyMissingError => err
          err.keys.each{ |key| instance_variable_set("@#{key}", CollectionSpace::Mapper::DEFAULT_CONFIG[key]) }
        end

        begin
          valid_response_mode
        rescue ConfigResponseModeError => err
          replacement_value = CollectionSpace::Mapper::DEFAULT_CONFIG[:response_mode]
          @response_mode = replacement_value
        end
      end

      def valid_response_mode
        valid = %w[normal verbose]
        unless valid.any?(@response_mode)
          raise ConfigResponseModeError.new("Invalid response_mode value in config: #{@response_mode}")
        end
      end
      
      def has_required_attributes
        required_keys = CollectionSpace::Mapper::DEFAULT_CONFIG.keys
        remaining_keys = required_keys - hash.keys
        unless remaining_keys.empty?
          raise ConfigKeyMissingError.new('Config missing key', remaining_keys)
        end
      end
    end
  end
end

