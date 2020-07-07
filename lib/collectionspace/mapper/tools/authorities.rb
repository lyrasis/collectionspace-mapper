# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module Authorities
        ::Authorities = CollectionSpace::Mapper::Tools::Authorities
        extend self

        # type - String - e.g. personauthorities, conceptauthorities
        # subtype - String - e.g. person, archculture
        # term - String
        # cache - collectionspace-refcache RefCache object
        def build_authority_urn(type, subtype, term, cache)
          domain = cache.domain
          identifier = Identifiers.short_identifier(term)
          "urn:cspace:#{domain}:#{type}:name(#{subtype}):item:name(#{identifier})'#{term}'"
        end
      end
    end
  end
end
