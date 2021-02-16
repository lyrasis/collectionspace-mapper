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
      class UnhandledConfigFormatError < StandardError; end
    end

    module Tools
      class Config
        attr_reader :hash
        def initialize(config)
          if config.is_a?(String)
          @hash = JSON.parse(config)
          symbolize
          elsif config.is_a?(Hash)
            @hash = config
          else
            raise CollectionSpace::Mapper::Errors::UnhandledConfigFormatError
          end
          validate
        end

        def date_config
          eo = emendate_option_names
          hash.select{ |opt, val| eo.include?(opt) }
        end
        
        private

        def emendate_option_names
          o = Emendate::Options.new
          o.options.keys
        end
        
        def symbolize
          @hash.transform_keys!(&:to_sym)
          symbolize_transforms if @hash[:transforms]
          symbolize_emendate_string_values
        end

        def symbolize_emendate_string_values
          eo = emendate_option_names
          newhash = {}
          
          hash.each do |opt, val|
            if eo.include?(opt) && val.is_a?(String)
              newhash[opt] = val.to_sym
            else
              newhash[opt] = val
            end
          end
          @hash = newhash
        end

        def symbolize_transforms
          @hash[:transforms].each do |field, hash|
            hash = hash.transform_keys!(&:to_sym)
            if hash[:replacements]
              hash[:replacements].map!{ |h| h.transform_keys!(&:to_sym) }
            end
          end
        end
        
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
