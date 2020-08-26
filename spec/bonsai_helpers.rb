# frozen_string_literal: true

module Helpers
  extend self
  
  def bonsai_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://bonsai.dev.collectionspace.org/cspace-services',
        username: 'admin@bonsai.collectionspace.org',
        password: 'Administrator'
      )
    )
  end
  
  def bonsai_cache
    cache_config = {
      domain: 'bonsai.collectionspace.org'
    }
    CollectionSpace::RefCache.new(config: cache_config, client: bonsai_client)
  end

  def populate_bonsai(cache)
    terms = [
      ['personauthorities', 'person', 'Ann Analyst', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'"],
      ['vocabularies', 'behrensmeyer', '2 - longitudinal cracks, exfoliation on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(2)'2 - longitudinal cracks, exfoliation on surface'"], 
    ]
    populate(cache, terms)
  end

end
