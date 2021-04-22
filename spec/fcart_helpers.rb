# frozen_string_literal: true

module Helpers
  extend self
  
  def fcart_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://fcart.dev.collectionspace.org/cspace-services',
        username: 'admin@fcart.collectionspace.org',
        password: 'Administrator'
      )
    )
  end
  
  def fcart_cache
    cache_config = {
      domain: 'fcart.collectionspace.org',
      search_enabled: false,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: fcart_client)
  end

  def populate_fcart(cache)
    terms = [
      ['personauthorities', 'person', 'Elizabeth', "urn:cspace:fcart.collectionspace.org:personauthorities:name(person):item:name(Elizabeth123)'Elizabeth'"]    ]
    populate(cache, terms)
  end

end
