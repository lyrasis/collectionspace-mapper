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
      ['locationauthorities', 'location', 'Abardares', "urn:cspace:core.collectionspace.org:locationauthorities:name(location):item:name(Abardares1599557570049)'Abardares'"],
      ['locationauthorities', 'offsite_sla', 'Lavington', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Lavington1599144699983)'Lavington'"],
      ['locationauthorities', 'offsite_sla', 'Ngong', "urn:cspace:core.collectionspace.org:locationauthorities:name(offsite_sla):item:name(Ngong1599557586466)'Ngong'"],
      ['orgauthorities', 'organization', '2021', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(20211599147173971)'2021'"],
      ['orgauthorities', 'organization', 'Broker', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Broker1599221487572)'Broker'"],
      ['orgauthorities', 'organization', 'Cuckoo', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Cuckoo1599463786824)'Cuckoo'"],
      ['orgauthorities', 'organization', 'Joseph Hills', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(JosephHills1599463935463)'Joseph Hills'"],
      ['orgauthorities', 'organization', 'Kremling', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Kremling1599464161204)'Kremling'"],
      ['orgauthorities', 'organization', 'MMG', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(MMG1599569514486)'MMG'"],
      ['orgauthorities', 'organization', 'Ninja', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Ninja1599147339325)'Ninja'"],
      ['orgauthorities', 'organization', 'Rock Nation', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(RockNation1599569481908)'Rock Nation'"],
      ['orgauthorities', 'organization', 'Sidarec', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Sidarec1599210955079)'Sidarec'"],
      ['orgauthorities', 'organization', 'TIm Herod', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(TImHerod1599144655199)'TIm Herod'"],
      ['orgauthorities', 'organization', 'Tesla', "urn:cspace:core.collectionspace.org:orgauthorities:name(organization):item:name(Tesla1599144565539)'Tesla'"],
      ['personauthorities', 'organization', 'King Kosa', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(KingKosa1599569726990)'King Kosa'"],
      ['personauthorities', 'person',  'Broooks', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Broooks1599221558583)'Broooks'"],
      ['personauthorities', 'person', '2020', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(20201599147149106)'2020'"],
      ['personauthorities', 'person', '254Glock', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(254Glock1599569494651)'254Glock'"],
      ['personauthorities', 'person', 'Abel', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Abel1599464025893)'Abel'"],
      ['personauthorities', 'person', 'Alexa', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Alexa1599557607978)'Alexa'"],
      ['personauthorities', 'person', 'Andrew Watts', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(AndrewWatts1599144553996)'Andrew Watts'"],
      ['personauthorities', 'person', 'Cardi', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Cardi1599569468209)'Cardi'"],
      ['personauthorities', 'person', 'Clemo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Clemo1599221473000)'Clemo'"],
      ['personauthorities', 'person', 'Clon', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Clon1599569543362)'Clon'"],
      ['personauthorities', 'person', 'Comodore', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Comodore1599463826401)'Comodore'"],
      ['personauthorities', 'person', 'Cooper Phil', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(CooperPhil1599144599479)'Cooper Phil'"],
      ['personauthorities', 'person', 'First Layer', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(FirstLayer1599463905818)'First Layer'"],
      ['personauthorities', 'person', 'Gomongo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Gomongo1599463746195)'Gomongo'"],
      ['personauthorities', 'person', 'Grace', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Grace1599569599918)'Grace'"],
      ['personauthorities', 'person', 'Henry', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Henry1599210937770)'Henry'"],
      ['personauthorities', 'person', 'Home Alone', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(HomeAlone1599144524188)'Home Alone'"],
      ['personauthorities', 'person', 'James', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(James1599210943727)'James'"],
      ['personauthorities', 'person', 'Jamo', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Jamo1599221465693)'Jamo'"],
      ['personauthorities', 'person', 'Joel', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Joel1599557736045)'Joel'"],
      ['personauthorities', 'person', 'John Allen', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnAllen1599144390263)'John Allen'"],
      ['personauthorities', 'person', 'John Kay', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(JohnKay1599210868122)'John Kay'"],
      ['personauthorities', 'person', 'Kali', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kali1599221504661)'Kali'"],
      ['personauthorities', 'person', 'Karanja', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Karanja1599211015378)'Karanja'"],
      ['personauthorities', 'person', 'Kev', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kev1599058769862)'Kev'"],
      ['personauthorities', 'person', 'Kimani', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kimani1599210926973)'Kimani'"],
      ['personauthorities', 'person', 'Kimonda', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Kimonda1599211004900)'Kimonda'"],
      ['personauthorities', 'person', 'Lebron', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Lebron1599557725925)'Lebron'"],
      ['personauthorities', 'person', 'Loan', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Loan1599210896616)'Loan'"],
      ['personauthorities', 'person', 'Mark Smith', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(MarkSmith)'Mark Smith'"],
      ['personauthorities', 'person', 'Meghan', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Meghan1599569567326)'Meghan'"],
      ['personauthorities', 'person', 'Nyauma', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(Nyauma1599210983879)'Nyauma'"],
      ['personauthorities', 'person', 'Shen Yeng', "urn:cspace:core.collectionspace.org:personauthorities:name(person):item:name(ShenYeng1599569685887)'Shen Yeng'"],
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
      ['vocabularies', 'conservationstatus', 'Analysis complete', "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(analysiscomplete)'Analysis complete'"],
      ['vocabularies', 'conservationstatus', 'Treatment approved', "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(treatmentapproved)'Treatment approved'"],
      ['vocabularies', 'conservationstatus', 'Treatment in progress', "urn:cspace:core.collectionspace.org:vocabularies:name(conservationstatus):item:name(treatmentinprogress)'Treatment in progress'"],
      ['vocabularies', 'datecertainty', 'Circa', "urn:cspace:core.collectionspace.org:vocabularies:name(datecertainty):item:name(circa)'Circa'"],
      ['vocabularies', 'dateera', 'BCE', "urn:cspace:core.collectionspace.org:vocabularies:name(dateera):item:name(bce)'BCE'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:core.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'datequalifier', 'Day(s)', "urn:cspace:core.collectionspace.org:vocabularies:name(datequalifier):item:name(days)'Day(s)'"],
      ['vocabularies', 'datequalifier', 'Year(s)', "urn:cspace:core.collectionspace.org:vocabularies:name(datequalifier):item:name(years)'Year(s)'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'board of trustees', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(board_of_trustees)'board of trustees'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'collection committee', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(collection_committee)'collection committee'"],
      ['vocabularies', 'deaccessionapprovalgroup', 'executive committee', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalgroup):item:name(executive_committee)'executive committee'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not approved', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_approved)'not approved'"],
      ['vocabularies', 'deaccessionapprovalstatus', 'not required', "urn:cspace:core.collectionspace.org:vocabularies:name(deaccessionapprovalstatus):item:name(not_required)'not required'"],
      ['vocabularies', 'entrymethod', 'Found on doorstep', "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(foundondoorstep)'Found on doorstep'"],
      ['vocabularies', 'entrymethod', 'Post', "urn:cspace:core.collectionspace.org:vocabularies:name(entrymethod):item:name(post)'Post'"],
      ['vocabularies', 'examinationphase', 'before treatment', "urn:cspace:core.collectionspace.org:vocabularies:name(examinationphase):item:name(beforetreatment)'before treatment'"],
      ['vocabularies', 'examinationphase', 'during treatment', "urn:cspace:core.collectionspace.org:vocabularies:name(examinationphase):item:name(duringtreatment)'during treatment'"],
      ['vocabularies', 'languages', 'Armenian', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(hye)'Armenian'"],
      ['vocabularies', 'languages', 'English', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(eng)'English'"],
      ['vocabularies', 'languages', 'Malaysian', "urn:cspace:core.collectionspace.org:vocabularies:name(languages):item:name(mal)'Malaysian'"],
      ['vocabularies', 'loanoutstatus', 'Authorized', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(authorized)'Authorized'"],
      ['vocabularies', 'loanoutstatus', 'Photography requested', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(photographyrequested)'Photography requested'"],
      ['vocabularies', 'loanoutstatus', 'Refused', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(refused)'Refused'"],
      ['vocabularies', 'loanoutstatus', 'Returned', "urn:cspace:core.collectionspace.org:vocabularies:name(loanoutstatus):item:name(returned)'Returned'"],
      ['vocabularies', 'otherpartyrole', 'Preparator', "urn:cspace:core.collectionspace.org:vocabularies:name(otherpartyrole):item:name(preparator)'Preparator'"],
      ['vocabularies', 'otherpartyrole', 'Technician', "urn:cspace:core.collectionspace.org:vocabularies:name(otherpartyrole):item:name(technician)'Technician'"],
      ['vocabularies', 'publishto', 'CollectionSpace Public Browser', "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(cspacepub)'CollectionSpace Public Browser'"],
      ['vocabularies', 'publishto', 'Culture Object', "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(cultureobject)'Culture Object'"],
      ['vocabularies', 'publishto', 'Omeka', "urn:cspace:core.collectionspace.org:vocabularies:name(publishto):item:name(omeka)'Omeka'"],
      ['vocabularies', 'treatmentpurpose', 'Exhibition', "urn:cspace:core.collectionspace.org:vocabularies:name(treatmentpurpose):item:name(exhibition)'Exhibition'"],
    ]
    populate(cache, terms)
  end
end
