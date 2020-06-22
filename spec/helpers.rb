# frozen_string_literal: true

module Helpers

  FIXTUREDIR = 'spec/fixtures/files'
  # returns RecordMapper hash read in from JSON file
  # path = String. Path to JSON file
  def get_json_record_mapper(path:)
    JSON.parse(File.read(path))
  end

  def get_xml_fixture(filename:)
    Nokogiri::XML(File.read("#{FIXTUREDIR}/#{filename}")){ |c| c.noblanks }.remove_namespaces!
  end

end
