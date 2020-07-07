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

end
