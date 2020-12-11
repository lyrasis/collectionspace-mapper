# frozen_string_literal: true

module Helpers
  extend self
  
  def pahma_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'http://173.255.245.71:8180/cspace-services',
        username: 'admin@pahma.cspace.berkeley.edu',
        password: 'Administrator'
      )
    )
  end
  
  def pahma_cache
    cache_config = {
      domain: 'pahma.cspace.berkeley.edu',
      search_enabled: false,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: anthro_client)
  end
end
