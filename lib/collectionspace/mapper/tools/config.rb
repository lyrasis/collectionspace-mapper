# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Errors
      ::Errors = CollectionSpace::Mapper::Errors
      class ConfigKeyMissingError < StandardError
        attr_reader :keys
        def initialize(message, keys)
          super(message)
          @keys = keys
        end
      end
    end

    module Tools
      class Config
        ::Config = CollectionSpace::Mapper::Tools::Config
        attr_reader :hash
        def initialize(hash)
          @hash = hash
        end

        def validate
          begin
            has_required_keys
          rescue => error
            error.keys.each do |key|
              value = Mapper::DEFAULT_CONFIG[key]
              @hash[key] = value
              Mapper::LOGGER.warn("#{error.message}: #{key}. Set to: #{value}")
            end
          end
        end

        private

        def has_required_keys
          required_keys = Mapper::DEFAULT_CONFIG.keys
          remaining_keys = required_keys - @hash.keys
          if remaining_keys.empty?
            true
          else
            raise Errors::ConfigKeyMissingError.new('Config missing key', remaining_keys)
          end
        end
      end
    end
  end
end
