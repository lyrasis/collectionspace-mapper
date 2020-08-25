# frozen_string_literal: true

require_relative './anthro_helpers'

module Helpers

  FIXTUREDIR = 'spec/fixtures/files/xml'

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

  def get_datahash(path:)
    JSON.parse(File.read(path))
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
  # removes fields not included in the RecordMapper mappings (which may be set in the XML due to weird
  #  default stuff in the application/services layer, but don't need to be in mapped XML)
  # testdoc should be the result of calling get_xml_fixture
  def test_xpaths(testdoc, mappings)
    xpaths = []
    testdoc.traverse { |node| xpaths <<  node.path }
    xpaths.sort!
    docpaths = []
    until xpaths.empty? do
      path = xpaths.shift
      docpaths << path unless xpaths.any?{ |e| e.start_with?(path) }
    end
    mappaths = mappings.map{ |m| "/document/#{m[:fullpath]}/#{m[:fieldname]}" }
    keeppaths = docpaths.select do |p|
      p = p.match(/^(.*)\//)[1].gsub(/\[\d+\]/, '')
      mappaths.include?(p)
    end
    reject = %w[computedCurrentLocation]
    keeppaths.reject{ |path| reject.any?{ |r| path[r] } }
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



end
