# frozen_string_literal: true

module Helpers

  FIXTUREDIR = 'spec/fixtures/files/xml'

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
      search_enabled: true,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: anthro_client)
  end

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

  # returns RecordMapper hash read in from JSON file
  # path = String. Path to JSON file
  # turns strings into symbols that removed when writing to JSON
  # we can't just use the json symbolize_names option because @docstructure keys must
  #   remain strings
  def get_json_record_mapper(path:)
    h = JSON.parse(File.read(path))
    h = h.transform_keys{ |k| k.to_sym }
    h[:config] = h[:config].transform_keys{ |key| key.to_sym }
    h[:mappings].each do |m|
      m.transform_keys!(&:to_sym)
      unless m[:transforms].empty?
        m[:transforms].transform_keys!(&:to_sym)
      end
    end
    h
  end

  # The way CollectionSpace uses different URIs for the same namespace prefix in the same
  #  document is irregular and makes it impossible to query a document via xpath if
  #  the namespaces are defined. For testing, remove them...
  def remove_namespaces(doc)
    doc = doc.clone
    doc.remove_namespaces!
    doc.xpath('/*/*').each{ |n| n.name = n.name.sub('ns2:', '') }
    doc
  end
  
  def get_xml_fixture(filename)
    doc = remove_namespaces(Nokogiri::XML(File.read("#{FIXTUREDIR}/#{filename}")){ |c| c.noblanks })
    # CSpace saves empty structured date fields with only a scalarValuesComputed value of false
    # we don't want to compare against these empty nodes
    doc.traverse{ |node| node.remove if node.name['Date'] && node.text == 'false' }
    # Drop empty nodes
    doc.traverse{ |node| node.remove unless node.text.match?(/\S/m) }
    # Drop sections of the document we don't write with the mapper
    doc.traverse{ |node| node.remove if node.name == 'collectionspace_core' || node.name == 'account_permission' }
    doc
  end

  # returns array of just the most specific xpaths from cleaned fixture XML for testing
  # testdoc should be the result of calling get_xml_fixture
  def test_xpaths(testdoc)
    xpaths = []
    testdoc.traverse { |node| xpaths <<  node.path }
    xpaths.sort!
    keeppaths = []
    until xpaths.empty? do
      path = xpaths.shift
      keeppaths << path unless xpaths.any?{ |e| e.start_with?(path) }
    end
    keeppaths
  end

  def standardize_value(string)
    if string.start_with?('urn:cspace')
      val = string.sub(/(item:name\([a-zA-Z]+)\d+(\)')/, '\1\2')
    else
      val = string
    end
    val
  end

  def populate(cache, terms)
    terms.each do |term|
      cache.put(*term)
    end
  end

  def populate_anthro(cache)
    terms = [
      ['personauthorities', 'person', 'Ann Analyst', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(AnnAnalyst1594848799340)'Ann Analyst'"],
      ['personauthorities', 'person', 'Gabriel Solares', "urn:cspace:anthro.collectionspace.org:personauthorities:name(person):item:name(GabrielSolares1594848906847)'Gabriel Solares'"],
['conceptauthorities', 'archculture', 'Blackfoot', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(archculture):item:name(Blackfoot1576172504869)'Blackfoot'"],
['conceptauthorities', 'concept', 'Birds', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(concept):item:name(Birds918181)'Birds'"],
['conceptauthorities', 'ethculture', 'Batak', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(ethculture):item:name(Batak1576172496916)'Batak'"],
['conceptauthorities', 'material_ca', 'Feathers', "urn:cspace:anthro.collectionspace.org:conceptauthorities:name(material_ca):item:name(Feathers918181)'Feathers'"],
['placeauthorities', 'place', 'York County, Pennsylvania', "urn:cspace:anthro.collectionspace.org:placeauthorities:name(place):item:name(YorkCountyPennsylvania)'York County, Pennsylvania'"],
['vocabularies', 'agerange', 'adolescent 26-75%', "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adolescent_26_75)'adolescent 26-75%'"],
['vocabularies', 'agerange', 'adult 0-25%', "urn:cspace:anthro.collectionspace.org:vocabularies:name(agerange):item:name(adult_0_25)'adult 0-25%'"],
['vocabularies', 'behrensmeyer', '2 - longitudinal cracks, exfoliation on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(2)'2 - longitudinal cracks, exfoliation on surface'"], 
['vocabularies', 'behrensmeyer', '5 - bone crumbling in situ, large splinters', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(5)'5 - bone crumbling in situ, large splinters'"],
['vocabularies', 'behrensmeyer', '1 - longitudinal and/or mosaic cracking present on surface', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(1)'1 - longitudinal and/or mosaic cracking present on surface'"], 
['vocabularies', 'behrensmeyer', '3 - fibrous texture, extensive exfoliation', "urn:cspace:anthro.collectionspace.org:vocabularies:name(behrensmeyer):item:name(3)'3 - fibrous texture, extensive exfoliation'"],
['vocabularies', 'bodyside', 'midline', "urn:cspace:anthro.collectionspace.org:vocabularies:name(bodyside):item:name(midline)'midline'"],
['vocabularies', 'mortuarytreatment', 'burned/unburned bone mixture', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(burnedunburnedbonemixture)'burned/unburned bone mixture'"],
['vocabularies', 'mortuarytreatment', 'embalmed', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(enbalmed)'enbalmed"],
['vocabularies', 'mortuarytreatment', 'excarnated', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(excarnated)'excarnated'"],
['vocabularies', 'mortuarytreatment', 'mummified', "urn:cspace:anthro.collectionspace.org:vocabularies:name(mortuarytreatment):item:name(mummified)'mummified'"],
['vocabularies', 'annotationtype', 'image made', "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(image_made)'image made'"],
['vocabularies', 'annotationtype', 'type', "urn:cspace:anthro.collectionspace.org:vocabularies:name(annotationtype):item:name(type)'type'"],
['vocabularies', 'dateera', 'CE', "urn:cspace:anthro.collectionspace.org:vocabularies:name(dateera):item:name(ce)'CE'"],
['vocabularies', 'inventorystatus', 'unknown', "urn:cspace:anthro.collectionspace.org:vocabularies:name(inventorystatus):item:name(unknown)'unknown'"],
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
    {
      'ageRange'=>'Adolescent 26 - 75%;Adult 0 - 25%',
      'annotationAuthor'=>'Ann Analyst; Gabriel Solares',
      'annotationDate'=>'12/19/2019;12/10/2019',
      'annotationNote'=>'Stored in coffee can; Photographed by staff',
      'annotationType'=>'type; image made',
      'behrensmeyerSingleLower'=>'1; 3',
      'behrensmeyerUpper'=>'2; 5',
      'bone'=>';fdgg',
      'collection'=>'Permanent Collection',
      'commingledRemainsNote'=>'crnote2;crnote2',
      'commingledRemainsSex'=>';Possibly female',
      'contentConceptAssociated'=>'Birds',
      'contentConceptMaterial'=>'Feathers',
      'count'=>';2',
      'culturalCareNote'=>nil,
      'dentition'=>';y',
      'dimension'=>'height^^width^^height^^width;height^^width^^height^^width',
      'dimensionSummary'=>'overall: 7 1/2 in x 5 1/2 in;image area: 5 1/2 in x 3 7/8 in',
      'fieldLocCounty'=>'York',
      'fieldLocPlace'=>'York County, Pennsylvania',
      'fieldLocState'=>'PA',
      'identDateGroup'=>'2019-09-30;4/5/2020',
      'inventoryStatus'=>'unknown',
      'limitationDetails'=>nil,
      'limitationLevel'=>nil,
      'limitationType'=>nil,
      'localityNote'=>'Sample locality note 1',
      'measurementUnit'=>'inches^^inches^^centimeters^^centimeters;inches^^inches^^centimeters^^centimeters',
      'minIndividuals'=>'1;2',
      'mortuaryTreatment'=>'burned/unburned bone mixture^^enbalmed;excarnated^^mummified',
      'mortuaryTreatmentNote'=>'mtnote1^^mtnote2;mtnote3^^mtnote4',
      'nagpraCategory'=>'subject to NAGPRA (unspec.);not subject to NAGPRA',
      'nagpraReportFiled'=>'Y',
      'nagpraReportFiledBy'=>'Ann Analyst',
      'nagpraReportFiledDate'=>'1/2/2019',
      'numberType'=>'isbn;oclc',
      'numberValue'=>'123;456',
      'objectNumber'=>'20CS.001.0001',
      'objectProductionNote'=>'Production note text.',
      'objectProductionPeopleArchculture'=>'Blackfoot',
      'objectProductionPeopleEthculture'=>'Batak',
      'objectProductionPeopleRole'=>'traditional makers; designed after',
      'recordStatus'=>'new',
      'repatriationNote'=>'Repatriation note 1; Repatriation note 2',
      'requestDate'=>nil,
      'requestOnBehalfOf'=>nil,
      'requester'=>nil,
      'sex'=>';Possibly female',
      'side'=>';midline',
      'title'=>'A Man;A Woman',
      'titleLanguage'=>'English;English',
      'titleTranslation'=>'Un Homme^^Hombre; Une Femme^^Fraulein',
      'titleTranslationLanguage'=>'French^^Spanish;French^^German',
      'titleType'=>'collection;generic',
      'value'=>'7.475^^5.475^^18.9865^^13.9065;5.5^^3.875^^13.97^^9.8425',
    }
    end
end
