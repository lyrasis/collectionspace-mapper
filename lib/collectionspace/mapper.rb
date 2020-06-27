require 'collectionspace/mapper/version'

require 'collectionspace/client'
require 'collectionspace/refcache'
require 'cspace_config_untangler'

require 'json'
require 'pp'

require 'nokogiri'


module CollectionSpace
  module Mapper
    ::Mapper = CollectionSpace::Mapper

    CONFIG = JSON.parse(File.read('config.json'), symbolize_names: true)
    
    require 'collectionspace/mapper/data_mapper'
    require 'collectionspace/mapper/data_processor'
    require 'collectionspace/mapper/data_validator'
  end    
end
