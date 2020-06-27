# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML document
    class DataMapper
      ::DataMapper = CollectionSpace::Mapper::DataMapper
      attr_reader :mapper, :cache, :blankdoc
      def initialize(record_mapper:, cache:)
        @mapper = record_mapper
        @cache = cache
        @blankdoc = build_xml
      end

      def map(data_hash)
        @blankdoc
      end
      
      
      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.document do
            @mapper[:docstructure].keys.each do |ns|
              nsh = namespace_hash(ns)
              xml.send(ns, nsh) do
                process_group(xml, [ns])
              end
            end
          end
        end
        Nokogiri::XML(builder.to_xml)
      end

      def process_group(xml, grouppath)
        @mapper[:docstructure].dig(*grouppath).keys.each do |key|
          thispath = grouppath.clone.append(key)
            xml.send(key){
              process_group(xml, thispath)
            }
        end
      end

      def namespace_hash(ns)
          {
            'xmlns:ns2' => @mapper[:config][:ns_uri][ns],
            'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance'
          }
      end
      
      # def write_fields(xml, path)
      #   @mapper.dig(*path).each do |mapping|
      #     val = get_value(mapping[:datacolumn])
      #     xml.send(mapping[:fieldname], val) unless val.nil? || val.empty?
      #   end
      # end

      # def get_value(column)
      #   @data.fetch(column, nil)
      # end
    end
  end
end
