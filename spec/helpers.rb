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
      domain: 'anthro.collectionspace.org'
    }
    CollectionSpace::RefCache.new(config: cache_config, client: client)
  end

  # returns RecordMapper hash read in from JSON file
  # path = String. Path to JSON file
  def get_json_record_mapper(path:)
    JSON.parse(File.read(path))
  end

  def get_xml_fixture(filename:)
    Nokogiri::XML(File.read("#{FIXTUREDIR}/#{filename}")){ |c| c.noblanks }.remove_namespaces!
  end

end
