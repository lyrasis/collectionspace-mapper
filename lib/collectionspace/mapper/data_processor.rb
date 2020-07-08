# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataProcessor
      ::DataProcessor = CollectionSpace::Mapper::DataProcessor
      attr_reader :recmapper, :cache, :validator, :datamapper
      def initialize(record_mapper:, cache:)
        @recmapper = record_mapper
        @cache = cache
        @validator = DataValidator.new(record_mapper: @recmapper, cache: @cache)
        #@datamapper = DataMapper.new(record_mapper: @recmapper, cache: @cache)
      end

      def process(record_hash)
        v = @validator.validate(record_hash)
        errs = v.select{ |h| h[:level] == :error }
        warns = v.select{ |h| h[:level] == :warning }
        if errs.size > 0
          {
            errors: errs,
            warnings: warns,
            data: record_hash,
            doc: nil,
            newterms: nil
          }
        else
          puts 'I will write doc'
          
        end
      end
      
      private
      
      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.document {
            @mapper.keys.each do |ns|
              xml.send(ns){
                process_group(xml, [ns])
              }
            end
          }
        end
        Nokogiri::XML(builder.to_xml)
      end

      def process_group(xml, grouppath)
        @mapper.dig(*grouppath).keys.each do |key|
          thispath = grouppath.clone.append(key)
          case key
          when :fieldmappings
            write_fields(xml, thispath)
          else
            xml.send(key){
              process_group(xml, thispath)
            }
          end
        end
      end
      
      def write_fields(xml, path)
        @mapper.dig(*path).each do |mapping|
          val = get_value(mapping[:datacolumn])
          xml.send(mapping[:fieldname], val) unless val.nil? || val.empty?
        end
      end

      def get_value(column)
        @data.fetch(column, nil)
      end
    end
  end
end
