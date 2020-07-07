# frozen_string_literal: true

module Helpers

  FIXTUREDIR = 'spec/fixtures/files'

  def anthro_cache
    client = CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://anthro.dev.collectionspace.org/cspace-services',
        username: 'admin@anthro.collectionspace.org',
        password: 'Administrator'
      )
    )
    cache_config = {
      domain: 'anthro.collectionspace.org',
      search_enabled: true,
      search_identifiers: false
    }
    CollectionSpace::RefCache.new(config: cache_config, client: client)
  end

  def bonsai_cache
    client = CollectionSpace::Client.new(
      CollectionSpace::Configuration.new(
        base_uri: 'https://bonsai.dev.collectionspace.org/cspace-services',
        username: 'admin@bonsai.collectionspace.org',
        password: 'Administrator'
      )
    )
    cache_config = {
      domain: 'bonsai.collectionspace.org'
    }
    CollectionSpace::RefCache.new(config: cache_config, client: client)
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

  def get_xml_fixture(filename:)
    Nokogiri::XML(File.read("#{FIXTUREDIR}/#{filename}")){ |c| c.noblanks }.remove_namespaces!
  end

    def anthro_co_1
    {'objectNumber'=>'20CS.001.0001',
     'numberValue'=>'123;456',
     'numberType'=>'isbn;oclc',
     'objectProductionPeopleArchculture'=>'Blackfoot',
     'objectProductionPeopleEthculture'=>'Batak',
     'objectProductionPeopleRole'=>'traditional makers; designed after',
     'collection'=>'Permanent Collection',
     'productionNote'=>'Production note text.',
     'fieldLocPlace'=>'York County, Pennsylvania',
     'fieldLocCounty'=>'York',
     'fieldLocState'=>'PA',
     'localityNote'=>'Sample locality note 1',
     'nagpraCategory'=>'subject to NAGPRA (unspec.);not subject to NAGPRA',
     'nagpraReportFiled'=>'Y',
     'nagpraReportFiledBy'=>'Ann Analyst',
     'nagpraReportFiledDate'=>'1/2/2019',
     'repatriationNote'=>'Repatriation note 1; Repatriation note 2',
     'minIndividuals'=>'1;2',
     'ageRange'=>'Adolescent 26 - 75%;Adult 0 - 25%',
     'side'=>';midline',
     'dentition'=>';true',
     'bone'=>';fdgg',
     'commingledRemainsSex'=>';Possibly female',
     'count'=>';2',
     'mortuaryTreatment'=>
       'burned/unburned bone mixture^^enbalmed;excarnated^^mummified',
     'mortuaryTreatmentNote'=>'mtnote1^^mtnote2;mtnote3^^mtnote4',
     'behrensmeyerSingleLower'=>'1; 3',
     'behrensmeyerUpper'=>'2; 5',
     'commingledRemainsNote'=>'crnote2;crnote2',
     'annotationNote'=>'Stored in coffee can; Photographed by staff',
     'annotationType'=>'type; image made',
     'annotationDate'=>'12/19/2019;12/10/2019',
     'annotationAuthor'=>'Ann Analyst; Gabriel Solares',
     'culturalCareNote'=>nil,
     'limitationDetails'=>nil,
     'limitationLevel'=>nil,
     'limitationType'=>nil,
     'requestDate'=>nil,
     'requester'=>nil,
     'requestOnBehalfOf'=>nil,
     'dimensionSummary'=>'overall: 7 1/2 in x 5 1/2 in;image area: 5 1/2 in x 3 7/8 in',
     'value'=>'7.475^^5.475^^18.9865^^13.9065;5.5^^3.875^^13.97^^9.8425',
     'dimension'=>'height^^width^^height^^width;height^^width^^height^^width',
     'measurementUnit'=>'inches^^inches^^centimeters^^centimeters;inches^^inches^^centimeters^^centimeters',
     'title'=>'A Man;A Woman',
     'titleLanguage'=>'English;English',
     'titleType'=>'collection;generic',
     'titleTranslation'=>'Un Homme^^Hombre; Une Femme^^Fraulein',
     'titleTranslationLanguage'=>'French^^Spanish;French^^German',
     'dataHashID'=>2
    }
  end
end
