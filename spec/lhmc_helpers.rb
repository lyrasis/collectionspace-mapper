# frozen_string_literal: true

module Helpers
  extend self
  
  def lhmc_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://lhmc.dev.collectionspace.org/cspace-services',
        username: 'admin@lhmc.collectionspace.org',
        password: 'Administrator'
      )
    )
  end
  
  def lhmc_cache
    cache_config = {
      domain: 'lhmc.collectionspace.org',
      search_enabled: true,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: lhmc_client)
  end

  def populate_lhmc(cache)
    terms = [
      ['personauthorities', 'person', 'Ann Analyst', "urn:cspace:lhmc.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'"],
      ['vocabularies', 'agerange', 'adolescent 26-75%', "urn:cspace:lhmc.collectionspace.org:vocabularies:name(agerange):item:name(adolescent_26_75)'adolescent 26-75%'"],
    ]
    populate(cache, terms)
  end
end
