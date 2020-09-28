# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module RefName
        extend self
        def build(source_type, type, subtype, term, cache)
          domain = cache.domain
          identifier = CollectionSpace::Mapper::Tools::Identifiers.short_identifier(term, source_type)
          "urn:cspace:#{domain}:#{type}:name(#{subtype}):item:name(#{identifier})'#{term}'"
        end
      end
    end
  end
end
