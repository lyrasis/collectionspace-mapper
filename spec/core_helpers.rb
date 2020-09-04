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
      ['personauthorities', 'person', 'Kali', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kali1599221504661)'Kali'"],
      ['orgauthorities', 'organization', 'Broker', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Broker1599221487572)'Broker'"],
      ['personauthorities', 'person', 'Jamo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Jamo1599221465693)'Jamo'"],
      ['personauthorities', 'person', 'Trepoz', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Trepoz1599221497512)'Trepoz'"],
      ['vocabularies', 'loanoutstatus', 'Authorized', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(authorized)'Authorized'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'board of trustees', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(board_of_trustees)'board of trustees'"],
      ['vocabularies', 'loanoutstatus', 'Photography requested', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(photographyrequested)'Photography requested'"],
      ['personauthorities', 'person',  'Broooks', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Broooks1599221558583)'Broooks'"],
      ['personauthorities', 'person', 'Clemo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Clemo1599221473000)'Clemo'"],
    ]
    populate(cache, terms)
  end
end
