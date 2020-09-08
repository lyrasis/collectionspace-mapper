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
      ['locationauthorities', 'offsite_sla', 'Lavington', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Lavington1599144699983)'Lavington'"],
      ['orgauthorities', 'organization', '2021', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(20211599147173971)'2021'"],
      ['orgauthorities', 'organization', 'Broker', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Broker1599221487572)'Broker'"],
      ['orgauthorities', 'organization', 'Ninja', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Ninja1599147339325)'Ninja'"],
      ['orgauthorities', 'organization', 'Sidarec', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Sidarec1599210955079)'Sidarec'"],
      ['orgauthorities', 'organization', 'TIm Herod', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(TImHerod1599144655199)'TIm Herod'"],
      ['orgauthorities', 'organization', 'Tesla', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Tesla1599144565539)'Tesla'"],
      ['personauthorities', 'person',  'Broooks', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Broooks1599221558583)'Broooks'"],
      ['personauthorities', 'person', '2020', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(20201599147149106)'2020'"],
      ['personauthorities', 'person', 'Andrew Watts', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(AndrewWatts1599144553996)'Andrew Watts'"],
      ['personauthorities', 'person', 'Clemo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Clemo1599221473000)'Clemo'"],
      ['personauthorities', 'person', 'Cooper Phil', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(CooperPhil1599144599479)'Cooper Phil'"],
      ['personauthorities', 'person', 'Henry', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Henry1599210937770)'Henry'"],
      ['personauthorities', 'person', 'Home Alone', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(HomeAlone1599144524188)'Home Alone'"],
      ['personauthorities', 'person', 'James', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(James1599210943727)'James'"],
      ['personauthorities', 'person', 'Jamo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Jamo1599221465693)'Jamo'"],
      ['personauthorities', 'person', 'John Allen', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnAllen1599144390263)'John Allen'"],
      ['personauthorities', 'person', 'John Kay', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnKay1599210868122)'John Kay'"],
      ['personauthorities', 'person', 'Kali', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kali1599221504661)'Kali'"],
      ['personauthorities', 'person', 'Karanja', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Karanja1599211015378)'Karanja'"],
      ['personauthorities', 'person', 'Kev', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kev1599058769862)'Kev'"],
      ['personauthorities', 'person', 'Kimani', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kimani1599210926973)'Kimani'"],
      ['personauthorities', 'person', 'Kimonda', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kimonda1599211004900)'Kimonda'"],
      ['personauthorities', 'person', 'Loan', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Loan1599210896616)'Loan'"],
      ['personauthorities', 'person', 'Mark Smith', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(MarkSmith)'Mark Smith'"],
      ['personauthorities', 'person', 'Nyauma', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Nyauma1599210983879)'Nyauma'"],
      ['personauthorities', 'person', 'Tim Joes', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(TimJoes1599144424859)'Tim Joes'"],
      ['personauthorities', 'person', 'Trepoz', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Trepoz1599221497512)'Trepoz'"],
      ['personauthorities', 'person', 'Trevor', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Trevor1599144536281)'Trevor'"],
      ['personauthorities', 'person', 'Troy', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Troy1599144360617)'Troy'"],
      ['placeauthorities', 'place', 'Chillspot', "urn:cspace:core.collectionspace.org:placeauthorities:name(place):item:name(Chillspot1599145441945)'Chillspot'"],
      ['vocabularies', 'collectionmethod', 'donation', "urn:cspace:core.collectionspace.org:vocabularies:name(collectionmethod):item:name(donation)'donation'"],
      ['vocabularies', 'collectionmethod', 'excavation', "urn:cspace:core.collectionspace.org:vocabularies:name(collectionmethod):item:name(excavation)'excavation'"],
      ['vocabularies', 'conditioncheckmethod', 'Observed', "urn:cspace:core.collectionspace.org:vocabularies:name(conditioncheckmethod):item:name(observed)'Observed'"],
      ['vocabularies', 'conditioncheckreason', 'Damaged in transit', "urn:cspace:core.collectionspace.org:vocabularies:name(conditioncheckreason):item:name(damagedintransit)'Damaged in transit'"],
      ['vocabularies', 'conditionfitness', 'Reasonable', "urn:cspace:core.collectionspace.org:vocabularies:name(conditionfitness):item:name(reasonable)'Reasonable'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'board of trustees', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(board_of_trustees)'board of trustees'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'collection committee', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(collection_committee)'collection committee'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'executive committee', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(executive_committee)'executive committee'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not approved', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_approved)'not approved'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not required', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_required)'not required'"],
      ['vocabularies', 'entrymethod', 'Found on doorstep', "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(foundondoorstep)'Found on doorstep'"],
      ['vocabularies', 'entrymethod', 'Post', "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(post)'Post'"],
      ['vocabularies', 'loanoutstatus', 'Authorized', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(authorized)'Authorized'"],
      ['vocabularies', 'loanoutstatus', 'Photography requested', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(photographyrequested)'Photography requested'"],
      ['vocabularies', 'loanoutstatus', 'Refused', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(refused)'Refused'"],
      ['vocabularies', 'loanoutstatus', 'Returned', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(returned)'Returned'"],
      ['locationauthorities', 'location', 'Khago', "urn:cspace:core.collectionspace.org:locationauthorities:name(location):item:name(Khago1599559772718)'Khago'"],
      ['locationauthorities', 'location', 'Stay', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Stay1599559824865)'Stay'"],
      ['citationauthorities', 'worldcat', 'Patiently', "urn:cspace:core.collectionspace.org:citationauthorities:name(worldcat):item:name(Patiently1599559993332)'Patiently'"],
      ['vocabularies', 'exhibitionreferencetype', 'Press release', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionreferencetype):item:name(pressrelease)'Press release'"],
      ['citationauthorities', 'citation', 'Wanting', "urn:cspace:core.collectionspace.org:citationauthorities:name(citation):item:name(Wanting1599560009399)'Wanting'"],
      ['vocabularies', 'newsarticle', 'News article', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionreferencetype):item:name(newsarticle)'News article'"],
      ['vocabularies', 'exhibitiontype', 'Temporary', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitiontype):item:name(temporary)'Temporary'"],
      ['personauthorities', 'ulan_pa', 'Chrus', "urn:cspace:core.collectionspace.org:personauthorities:name(ulan_pa):item:name(Chrus1599559702930)'Chrus'"],
      ['orgauthorities', 'organization', 'Martin', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Martin1599559712783)'Martin'"],
      ['vocabularies', 'exhibitionstatus', 'Preliminary object list created', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionstatus):item:name(preliminaryobjectlistcreated)'Preliminary object list created'"],
      ['vocabularies', 'exhibitionstatus', 'Preliminary object list created', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionstatus):item:name(preliminaryobjectlistcreated)'Preliminary object list created'"],
      ['personauthorities', 'person', 'Busy', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Busy1599559723432)'Busy'"],
      ['orgauthorities', 'ulan_oa', 'Signal', "urn:cspace:core.collectionspace.org:orgauthorities:name(ulan_oa):item:name(Signal1599559737158)'Signal'"],
      ['vocabularies', 'exhibitionpersonrole', 'Educator', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionpersonrole):item:name(educator)'Educator'"],
      ['personauthorities', 'ulan_pa', 'We go', "urn:cspace:core.collectionspace.org:personauthorities:name(ulan_pa):item:name(Wego1599559866517)'We go'"],
      ['vocabularies', 'exhibitionpersonrole', 'Public programs coordinator', "urn:cspace:core.collectionspace.org:vocabularies:name(exhibitionpersonrole):item:name(publicprogramscoordinator)'Public programs coordinator'"],
      ['orgauthorities', 'ulan_oa', 'Again', "urn:cspace:core.collectionspace.org:orgauthorities:name(ulan_oa):item:name(Again1599559881266)'Again'"],
      ['orgauthorities', 'organization', 'breakup', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(breakup1599559909048)'breakup'"],
    ]
    populate(cache, terms)
  end
end
