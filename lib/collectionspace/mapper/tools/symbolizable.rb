# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module Symbolizable
        extend self

        # This is a Tools mixin becasue it is a :reek:UtilityFunction
        def symbolize(hash)
          hash.transform_keys{ |key| key.to_sym }
        end
      end
    end
  end
end

