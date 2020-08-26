# frozen_string_literal: true

require 'bundler/setup'
require 'collectionspace/mapper'
require_relative './helpers'

# RubyProf.start

config = {
  delimiter: ';',
  subgroup_delimiter: '^^'
}
Helpers.populate_anthro(Helpers.anthro_cache)

rm_anthro_co = Helpers.get_json_record_mapper(path: 'spec/fixtures/files/mappers/anthro_4_0_0-collectionobject.json')
handler = DataHandler.new(record_mapper: rm_anthro_co, cache: Helpers.anthro_cache, client: Helpers.anthro_client, config: config)

datahash = Helpers.get_datahash(path: 'spec/fixtures/files/datahashes/anthro/collectionobject2.json')

v_result = handler.validate(datahash)

if v_result.valid?
  result = handler.process(datahash)
  
end

# result = RubyProf.stop
# printer = RubyProf::MultiPrinter.new(result)
# printer.print(path: './tmp', profile: 'workflow')
