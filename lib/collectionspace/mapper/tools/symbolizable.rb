# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module Symbolizable
        extend self

        def symbolize(hash)
          hash.transform_keys{ |key| key.to_sym }
        end

        def symbolize_transforms(transforms)
          transforms.each do |field, hash|
            hash = hash.transform_keys!(&:to_sym)
            replacements = hash[:replacements]
            return hash unless replacements
            symbolize_replacements(replacements)
            hash
          end
        end

        def symbolize_replacements(replacements)
          replacements.map!{ |h| h.transform_keys!(&:to_sym) }
        end
        
      end
    end
  end
end

