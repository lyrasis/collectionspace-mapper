# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Errors
      class ConfigKeyMissingError < StandardError
        attr_reader :keys
        def initialize(message, keys)
          super(message)
          @keys = keys
        end
      end

      class ConfigResponseModeError < StandardError; end
    end

    module Tools
      class Config
        attr_reader :hash
        def initialize(hash)
          @hash = hash
          validate
        end

        private
        
        def validate
          begin
            has_required_keys
          rescue => error
            error.keys.each do |key|
              value = CollectionSpace::Mapper::DEFAULT_CONFIG[key]
              @hash[key] = value
              CollectionSpace::Mapper::LOGGER.warn("#{error.message}: #{key}. Set to: #{value}")
            end
          end

          begin
            valid_response_mode
          rescue => error
            replacement_value = CollectionSpace::Mapper::DEFAULT_CONFIG[:response_mode]
            @hash[:response_mode] = replacement_value
            CollectionSpace::Mapper::LOGGER.warn("#{error.message}. Reset to: #{replacement_value}")
          end
        end

        private

        def valid_response_mode
          valid = %w[normal verbose]
          value = @hash[:response_mode]
          unless valid.any?(value)
            raise CollectionSpace::Mapper::Errors::ConfigResponseModeError.new("Invalid response_mode value in config: #{value}")
          end
        end
        
        def has_required_keys
          required_keys = CollectionSpace::Mapper::DEFAULT_CONFIG.keys
          remaining_keys = required_keys - @hash.keys
          unless remaining_keys.empty?
            raise CollectionSpace::Mapper::Errors::ConfigKeyMissingError.new('Config missing key', remaining_keys)
          end
        end
      end
    end
  end
end
