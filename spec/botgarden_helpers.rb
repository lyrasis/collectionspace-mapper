# frozen_string_literal: true

module Helpers
  extend self
  
  def botgarden_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://botgarden.dev.collectionspace.org/cspace-services',
        username: 'admin@botgarden.collectionspace.org',
        password: 'Administrator'
      )
    )
  end
  
  def botgarden_cache
    cache_config = {
      domain: 'botgarden.collectionspace.org',
      search_enabled: true,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: botgarden_client)
  end

  def populate_botgarden(cache)
    terms = [
      ['citationauthorities', 'citation', 'Sp. Pl. 2: 899. 1753', "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(citation):item:name(SpPl289917531599238184211)'Sp. Pl. 2: 899. 1753'"],
      ['citationauthorities', 'worldcat', 'Bull. Torrey Bot. Club', "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(worldcat):item:name(BullTorreyBotClub331599245358364)'Bull. Torrey Bot. Club 33'"],
      ['citationauthorities', 'citation', 'FNA Volume 19', "urn:cspace:botgarden.collectionspace.org:citationauthorities:name(citation):item:name(FNAVolume191599238760383)'FNA Volume 19'"],
      ['orgauthorities', 'organization', 'FVA', "urn:cspace:botgarden.collectionspace.org:orgauthorities:name(organization):item:name(FVA1599246022216)'FVA'"],
      ['personauthorities', 'person', 'Linnaeus, Carl', "urn:cspace:botgarden.collectionspace.org:personauthorities:name(person):item:name(LinnaeusCarl1599238374086)'Linnaeus, Carl'"],
      ['vocabularies', 'languages', 'English', "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(eng)'English'"],
      ['vocabularies', 'languages', 'French', "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'"],
      ['vocabularies', 'languages', 'Latin', "urn:cspace:botgarden.collectionspace.org:vocabularies:name(languages):item:name(lat)'Latin'"],
      ['vocabularies', 'taxontermflag', 'valid', "urn:cspace:botgarden.collectionspace.org:vocabularies:name(taxontermflag):item:name(valid)'valid'"],
      ['vocabularies', 'taxontermflag', 'invalid', "urn:cspace:botgarden.collectionspace.org:vocabularies:name(taxontermflag):item:name(invalid)'invalid'"],
      ['taxonomyauthority', 'taxon', 'Tropez', "urn:cspace:botgarden.collectionspace.org:taxonomyauthority:name(taxon):item:name(Tropez1599750195530)'Tropez'"],
      ['taxonomyauthority', 'taxon', 'Domestic', "urn:cspace:botgarden.collectionspace.org:taxonomyauthority:name(taxon):item:name(Domestic1599750187683)'Domestic'"],
    ]
    populate(cache, terms)
  end
end
