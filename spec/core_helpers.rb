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
      ['personauthorities', 'person', '2020', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(20201599147149106)'2020'"],
      ['personauthorities', 'person', 'Kev', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kev1599058769862)'Kev'"],
      ['personauthorities', 'person', 'Mark Smith', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(MarkSmith)'Mark Smith'"],
      ['personauthorities', 'person', 'Andrew Watts', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(AndrewWatts1599144553996)'Andrew Watts'"],
      ['personauthorities', 'person', 'Cooper Phil', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(CooperPhil1599144599479)'Cooper Phil'"],
      ['personauthorities', 'person', 'Troy', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Troy1599144360617)'Troy'"],
      ['personauthorities', 'person', 'John Allen', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnAllen1599144390263)'John Allen'"],
      ['personauthorities', 'person', 'Tim Joes', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(TimJoes1599144424859)'Tim Joes'"],
      ['personauthorities', 'person', 'Home Alone', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(HomeAlone1599144524188)'Home Alone'"],
      ['personauthorities', 'person', 'Trevor', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Trevor1599144536281)'Trevor'"],
      ['placeauthorities', 'place', 'Chillspot', "urn:cspace:core.collectionspace.org:placeauthorities:name(place):item:name(Chillspot1599145441945)'Chillspot'"],
      ['orgauthorities', 'organization', '2021', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(20211599147173971)'2021'"],
      ['orgauthorities', 'organization', 'TIm Herod', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(TImHerod1599144655199)'TIm Herod'"],
      ['orgauthorities', 'organization', 'Tesla', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Tesla1599144565539)'Tesla'"],
      ['orgauthorities', 'organization', 'Ninja', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Ninja1599147339325)'Ninja'"],
      ['vocabularies', 'collectionmethod', 'donation', "urn:cspace:core.collectionspace.org:vocabularies:name(collectionmethod):item:name(donation)'donation'"],
      ['vocabularies', 'collectionmethod', 'excavation', "urn:cspace:core.collectionspace.org:vocabularies:name(collectionmethod):item:name(excavation)'excavation'"],
      ['vocabularies', 'entrymethod', 'Post', "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(post)'Post'"],
      ['vocabularies', 'entrymethod', 'Found on doorstep', "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(foundondoorstep)'Found on doorstep'"],
      ['vocabularies', 'conditioncheckreason', 'Damaged in transit', "urn:cspace:core.collectionspace.org:vocabularies:name(conditioncheckreason):item:name(damagedintransit)'Damaged in transit'"],
      ['vocabularies', 'conditioncheckmethod', 'Observed', "urn:cspace:core.collectionspace.org:vocabularies:name(conditioncheckmethod):item:name(observed)'Observed'"],
      ['vocabularies', 'conditionfitness', 'Reasonable', "urn:cspace:core.collectionspace.org:vocabularies:name(conditionfitness):item:name(reasonable)'Reasonable'"],
      ['locationauthorities', 'offsite_sla', 'Lavington', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Lavington1599144699983)'Lavington'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not approved', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_approved)'not approved'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'board of trustees', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(board_of_trustees)'board of trustees'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'executive committee', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(executive_committee)'executive committee'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'collection committee', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(collection_committee)'collection committee'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not required', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_required)'not required'"],
    ]
    populate(cache, terms)
  end
end
