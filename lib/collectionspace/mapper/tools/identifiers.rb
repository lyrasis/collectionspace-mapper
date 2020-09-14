# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module Identifiers
        ::Identifiers = CollectionSpace::Mapper::Tools::Identifiers
        extend self
        def short_identifier(name, source_type)
          v = name.gsub(/\W/, '')
          source_type == :authority ? "#{v}#{XXhash.xxh32(v)}" : v
        end
      end
    end
  end
end
