# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module Date
        ::Date = CollectionSpace::Mapper::Tools::Date
        extend self

        class StructuredDate
          attr_reader :date_string, :parser_result

          def initialize(date_string, client)
            @date_string = date_string
            sdquery = "structureddates?dateToParse=#{date_string}"
            response = client.get(sdquery)
            if response.status_code == 200
              @parser_result = response.result['structureddate_common']
            else
              @parser_result = { 'dateDisplayDate' => date_string,
                                'scalarValuesComputed' => 'false'
                               }
            end
          end

          def map(doc, parentnode, groupname)
            @parser_result.each do |datefield, value|
              value = DateTime.parse(value).iso8601(3).sub('+00:00', "Z") if datefield['ScalarValue']
              
            end
          end
        end
      end
    end
  end
end
