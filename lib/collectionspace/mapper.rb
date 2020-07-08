require 'collectionspace/mapper/version'

require 'collectionspace/client'
require 'collectionspace/refcache'
require 'cspace_config_untangler'

require 'json'
require 'pp'

require 'nokogiri'
require 'xxhash'


module CollectionSpace
  module Mapper
    ::Mapper = CollectionSpace::Mapper

    CONFIG = JSON.parse(File.read('config.json'), symbolize_names: true)

    require 'collectionspace/mapper/data_mapper'
    require 'collectionspace/mapper/data_processor'
    require 'collectionspace/mapper/data_splitter'
    require 'collectionspace/mapper/data_validator'
    require 'collectionspace/mapper/value_transformer'
    require 'collectionspace/mapper/xpath_mapper'

    require 'collectionspace/mapper/tools/authorities'
    require 'collectionspace/mapper/tools/identifiers'
    require 'collectionspace/mapper/tools/vocabularies'
  end    
end
