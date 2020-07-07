# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module Identifiers
        ::Identifiers = CollectionSpace::Mapper::Tools::Identifiers
        extend self
        def short_identifier(name)
          v = name.gsub(/\W/, '')
          "#{v}#{XXhash.xxh32(v)}"
        end
      end
    end
  end
end
