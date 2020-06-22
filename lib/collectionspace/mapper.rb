require 'collectionspace/mapper/version'

require 'collectionspace/client'
require 'collectionspace/refcache'
require 'cspace_config_untangler'

require 'json'
require 'pp'

require 'nokogiri'


module CollectionSpace
  module Mapper
    CONFIG = JSON.parse(File.read('config.json'))
    puts CONFIG
    require 'collectionspace/mapper/data_mapper'
  end    
end
