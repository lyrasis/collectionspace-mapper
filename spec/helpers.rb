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
['placeauthorities', 'place', 'York County, Pennsylvania', "urn:cspace:anthro.collectionspace.org:placeauthorities:name(place):item:name(YorkCountyPennsylvania)'York County, Pennsylvania'"]
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
      'count'=>';2',
      'culturalCareNote'=>nil,
      'dentition'=>';y',
      'dimension'=>'height^^width^^height^^width;height^^width^^height^^width',
      'dimensionSummary'=>'overall: 7 1/2 in x 5 1/2 in;image area: 5 1/2 in x 3 7/8 in',
      'fieldLocCounty'=>'York',
      'fieldLocPlace'=>'York County, Pennsylvania',
      'fieldLocState'=>'PA',
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
