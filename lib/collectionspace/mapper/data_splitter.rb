# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataSplitter
      ::DataSplitter = CollectionSpace::Mapper::DataSplitter
      attr_reader :data, :result
      def initialize(data)
        @data = data.strip
        @delim = Mapper::CONFIG[:delim]
        @sgdelim = Mapper::CONFIG[:subgroup_delim]
      end
    end

    class SimpleSplitter < DataSplitter
      ::SimpleSplitter = CollectionSpace::Mapper::SimpleSplitter
      def initialize(data)
        super
        # negative limit parameter turns off suppression of trailing empty fields
        @result = @data.split(@delim, -1).map{ |e| e.strip }
      end
    end

    class SubgroupSplitter < DataSplitter
      ::SubgroupSplitter = CollectionSpace::Mapper::SubgroupSplitter
      def initialize(data)
        super
        # negative limit parameter turns off suppression of trailing empty fields
        groups = @data.split(@delim, -1).map{ |e| e.strip }
        @result = groups.map{ |g| g.split(@sgdelim, -1).map{ |e| e.strip } }
      end
    end
  end
end
