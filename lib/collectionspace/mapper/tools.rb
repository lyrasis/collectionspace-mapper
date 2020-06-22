# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      # retrieves RecordMapper hash from cspace-config-untangler
      class RecordMapperUntangler
        ::RecordMapperUntangler = CollectionSpace::Mapper::Tools::RecordMapperUntangler
        attr_reader :to_h
        def initialize(profile:, rectype:)
          @profile = profile
          @rectype = rectype
          @to_h = CCU::RecordMapper.new(profile: @profile, rectype: @rectype).hash
        end
      end

      # retrieves RecordMapper hash from CCU
      class RecordMapperJson
        ::RecordMapperJson = CollectionSpace::Mapper::Tools::RecordMapperJson
        attr_reader :to_h
        def initialize(file:)
          @file = file
          @to_h = JSON.parse(File.read(@file))
        end
      end
    end
  end
end
