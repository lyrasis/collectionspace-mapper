# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module Vocabularies
        ::Vocabularies = CollectionSpace::Mapper::Tools::Vocabularies
        extend self

        # vocabulary - String - e.g. languages, inventorystatus
        # term - String
        # cache - collectionspace-refcache RefCache object
        def build_vocabulary_urn(vocabulary, term, cache)
          domain = cache.domain
          identifier = Identifiers.short_identifier(term)
          "urn:cspace:#{domain}:vocabularies:name(#{vocabulary}):item:name(#{identifier})'#{term}'"
        end
      end
    end
  end
end
