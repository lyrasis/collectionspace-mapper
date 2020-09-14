# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module RefName
        ::RefName = CollectionSpace::Mapper::Tools::RefName
        extend self
        def build(source_type, type, subtype, term, cache)
          domain = cache.domain
          identifier = Identifiers.short_identifier(term, source_type)
          "urn:cspace:#{domain}:#{type}:name(#{subtype}):item:name(#{identifier})'#{term}'"
        end
      end
    end
  end
end
