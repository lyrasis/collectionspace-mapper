# frozen_string_literal: true

module Helpers
    extend self
    
    def core_client
      CollectionSpace::Client.new(
        CollectionSpace::Configuration.new(
          base_uri: 'https://core.dev.collectionspace.org/cspace-services',
          username: 'admin@core.collectionspace.org',
          password: 'Administrator'
        )
      )
    end
    
    def core_cache
      cache_config = {
        domain: 'core.collectionspace.org'
      }
      CollectionSpace::RefCache.new(config: cache_config, client: core_client)
    end
  
    def populate_core(cache)
      terms = [
        ['personauthorities', 'person', 'Kev', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kev1599058769862)'Kev'"],
      ]
      populate(cache, terms)
    end
  end
  