# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark'
require 'collectionspace/mapper'
require 'facets/array/before'
require_relative './helpers'

config = {}
rm_anthro_co = Helpers.get_json_record_mapper('spec/fixtures/files/mappers/anthro_4_0_0-collectionobject.json')
dh = DataHandler.new(record_mapper: rm_anthro_co, cache: Helpers.anthro_cache, client: Helpers.anthro_client, config: config)

fixture = 'anthro/collectionobject1.xml'
fdoc = Helpers.get_xml_fixture(fixture)

n = 10000

xpaths = Helpers.test_xpaths(fdoc, dh.mapper.mappings)


Benchmark.bm do |benchmark|
  benchmark.report('ext') do
    n.times do
      Helpers.field_value_xpaths(xpaths)
    end
  end
  benchmark.report('new') do
    n.times do
      Helpers.field_value_xpaths_new(xpaths)
    end
  end
end

