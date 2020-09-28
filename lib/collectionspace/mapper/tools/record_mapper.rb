# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module RecordMapper
        extend self

        def convert(json)
          h = json.transform_keys{ |k| k.to_sym }
          h[:config] = h[:config].transform_keys{ |key| key.to_sym }
          h[:mappings].each do |m|
            m.transform_keys!(&:to_sym)
            unless m[:transforms].empty?
              m[:transforms].transform_keys!(&:to_sym)
            end
          end
          h
        end

      end
    end
  end
end
