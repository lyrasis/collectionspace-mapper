# frozen_string_literal: true

module Helpers
  extend self
  
  def anthro_client
    CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://anthro.dev.collectionspace.org/cspace-services',
        username: 'admin@anthro.collectionspace.org',
        password: 'Administrator'
      )
    )
  end
  
  def anthro_cache
    cache_config = {
      domain: 'anthro.collectionspace.org',
      search_enabled: false,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: anthro_client)
  end

  def populate_anthro(cache)
    terms = [
      ['conceptauthorities', 'archculture', 'Blackfoot', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(archculture):item:name(Blackfoot1576172504869)'Blackfoot'"],
      ['conceptauthorities', 'concept', 'Birds', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(concept):item:name(Birds918181)'Birds'"],
      ['conceptauthorities', 'ethculture', 'Batak', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Batak1576172496916)'Batak'"],
      ['conceptauthorities', 'material_ca', 'Feathers', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(material_ca):item:name(Feathers918181)'Feathers'"],
      ['orgauthorities', 'organization', 'Organization 1', "urn:cspace:anthro.collectionspace.org:orgauthorities:name(organization):item:name(Organization11587136583004)'Organization 1'"],
      ['personauthorities', 'person', 'Ann Analyst', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'"],
      ['personauthorities', 'person', 'Gabriel Solares', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1594848906847)'Gabriel Solares'"],
      ['placeauthorities', 'place', 'York County, Pennsylvania', "urn:cspace:anthro.collectionspace.org:placeauthorities:name(place):item:name(YorkCountyPennsylvania)'York County, Pennsylvania'"],
      ['vocabularies', 'agerange', 'adolescent 26-75%', "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adolescent_26_75)'adolescent 26-75%'"],
      ['vocabularies', 'agerange', 'adult 0-25%', "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adult_0_25)'adult 0-25%'"],
      ['vocabularies', 'annotationtype', 'image made', "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(image_made)'image made'"],
      ['vocabularies', 'annotationtype', 'type', "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(type)'type'"],
      ['vocabularies', 'behrensmeyer', '0 - no cracking or flaking on bone surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(0)'0 - no cracking or flaking on bone surface'"], 
      ['vocabularies', 'behrensmeyer', '1 - longitudinal and/or mosaic cracking present on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(1)'1 - longitudinal and/or mosaic cracking present on surface'"], 
      ['vocabularies', 'behrensmeyer', '2 - longitudinal cracks, exfoliation on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(2)'2 - longitudinal cracks, exfoliation on surface'"], 
      ['vocabularies', 'behrensmeyer', '3 - fibrous texture, extensive exfoliation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(3)'3 - fibrous texture, extensive exfoliation'"],
      ['vocabularies', 'behrensmeyer', '5 - bone crumbling in situ, large splinters', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(5)'5 - bone crumbling in situ, large splinters'"],
      ['vocabularies', 'bodyside', 'midline', "urn:cspace:anthro.collectionspace.org:vocabularies:name(bodyside):item:name(midline)'midline'"],
      ['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
      ['vocabularies', 'inventorystatus', 'accessioned', "urn:cspace:anthro.collectionspace.org:vocabularies:name(inventorystatus):item:name(accessioned)'accessioned'"],
      ['vocabularies', 'inventorystatus', 'unknown', "urn:cspace:anthro.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'unknown'"],
      ['vocabularies', 'languages', 'Chinese', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(zho)'Chinese'"],
      ['vocabularies', 'languages', 'English', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(eng)'English'"],
      ['vocabularies', 'languages', 'French', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(fra)'French'"],
      ['vocabularies', 'languages', 'German', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(deu)'German'"],
      ['vocabularies', 'languages', 'Spanish', "urn:cspace:anthro.collectionspace.org:vocabularies:name(languages):item:name(spa)'Spanish'"],
      ['vocabularies', 'limitationlevel', 'recommendation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(limitationlevel):item:name(recommendation)'recommendation'"],
      ['vocabularies', 'limitationlevel', 'restriction', "urn:cspace:anthro.collectionspace.org:vocabularies:name(limitationlevel):item:name(restriction)'restriction'"],
      ['vocabularies', 'limitationtype', 'lending', "urn:cspace:anthro.collectionspace.org:vocabularies:name(limitationtype):item:name(lending)'lending'"],
      ['vocabularies', 'limitationtype', 'publication', "urn:cspace:anthro.collectionspace.org:vocabularies:name(limitationtype):item:name(publication)'publication'"],
      ['vocabularies', 'mortuarytreatment', 'burned/unburned bone mixture', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(burnedunburnedbonemixture)'burned/unburned bone mixture'"],
      ['vocabularies', 'mortuarytreatment', 'enbalmed', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(enbalmed)'enbalmed'"],
      ['vocabularies', 'mortuarytreatment', 'excarnated', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(excarnated)'excarnated'"],
      ['vocabularies', 'mortuarytreatment', 'mummified', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(mummified)'mummified'"],
      ['vocabularies', 'nagpracategory', 'not subject to NAGPRA', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpracategory):item:name(nonNagpra)'not subject to NAGPRA'"],
      ['vocabularies', 'nagpracategory', 'subject to NAGPRA (unspec.)', "urn:cspace:anthro.collectionspace.org:vocabularies:name(nagpracategory):item:name(subjectToNAGPRA)'subject to NAGPRA (unspec.)'"],
      ['vocabularies', 'prodpeoplerole', 'designed after', "urn:cspace:anthro.collectionspace.org:vocabularies:name(prodpeoplerole):item:name(designedAfter)'designed after'"],
      ['vocabularies', 'prodpeoplerole', 'traditional makers', "urn:cspace:anthro.collectionspace.org:vocabularies:name(prodpeoplerole):item:name(traditionalMakers)'traditional makers'"],
      ['vocabularies', 'publishto', 'DPLA', "urn:cspace:anthro.collectionspace.org:vocabularies:name(publishto):item:name(dpla)'DPLA'"],
      ['vocabularies', 'publishto', 'Omeka', "urn:cspace:anthro.collectionspace.org:vocabularies:name(publishto):item:name(omeka)'Omeka'"],
    ]
    populate(cache, terms)
  end

  def anthro_co_1
    get_datahash(path: 'spec/fixtures/files/datahashes/anthro/collectionobject1.json')
  end
end
