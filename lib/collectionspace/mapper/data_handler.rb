# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML document
    class DataHandler
      ::DataHandler = CollectionSpace::Mapper::DataHandler
      attr_reader :mapper, :cache, :client, :blankdoc, :defaults, :validator
      def initialize(record_mapper:, client:, cache:, config:)
        @mapper = record_mapper
        @mapper[:xpath] = xpath_hash
        Mapper.const_set('CONFIG', config)
        @cache = cache
        @client = client
        @blankdoc = build_xml
        @defaults = Mapper::CONFIG[:default_values] ? Mapper::CONFIG[:default_values].transform_keys(&:downcase) : nil
        merge_config_transforms
        @validator = DataValidator.new(record_mapper: @mapper, cache: @cache)
      end

      def validate(data_hash)
        @validator.validate(data_hash)
      end

      def map(data_hash)
        datamapper = DataMapper.new(data_hash, self)
        datamapper.result
      end

      private
      
      # you can specify per-data-key transforms in your config.json
      # This method merges the config.json transforms into the RecordMapper field
      #   mappings for the appropriate fields
      def merge_config_transforms
        return unless Mapper::CONFIG[:transforms]
        Mapper::CONFIG[:transforms].each do |datacol, x|
          target = @mapper[:mappings].select{ |m| m[:datacolumn] == datacol }
          unless target.empty?
            target = target.first
            target[:transforms] = target[:transforms].merge(x)
          end
        end
      end

      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.document do
            @mapper[:docstructure].keys.each do |ns|
              xml.send(ns) do
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

      # builds hash containing information to be used in mapping the fields that are
      #  children of each xpath
      # keys - the XML doc xpaths that contain child fields
      # value is a hash with the following keys:
      #  :parent - String, xpath of parent (empty if it's a top level namespace)
      #  :children - Array, of xpaths occuring beneath this one in the document
      #  :is_group - Boolean, whether grouping of fields at xpath is a repeating field group
      #  :is_subgroup - Boolean, whether grouping of fields is subgroup of another group
      #  :subgroups - Array, xpaths of any repeating field groups that are children of an xpath
      #     that itself contains direct child fields
      #  :mappings - Array, of fieldmappings that are children of this xpath
      def xpath_hash
        h = {}
        # create key for each xpath containing fields, and set up structure of its value
        @mapper[:mappings].each do |mapping|
          mapping[:fullpath] = ( [mapping[:namespace]] + mapping[:xpath] ).flatten.join('/')
          h[mapping[:fullpath]] = {parent: '', children: [], is_group: false, is_subgroup: false, subgroups: [], mappings: []}
        end
        # add fieldmappings for children of each xpath
        @mapper[:mappings].each do |mapping|
          h[mapping[:fullpath]][:mappings] << mapping
        end
        # populate other attributes
        # populate parent of all non-top xpaths
        h.each do |xpath, ph|
          if xpath['/']
            keys = h.keys - [xpath]
            keys = keys.select{ |k| xpath[k] }
            keys = keys.sort{ |a, b| b.length <=> a.length }
            ph[:parent] = keys[0] unless keys.empty?
          end
        end

        # populate children
        h.each do |xpath, ph|
          keys = h.keys - [xpath]
          ph[:children] = keys.select{ |k| k.start_with?(xpath) }
        end
        
        # populate subgroups
        h.each do |xpath, ph|
          keys = h.keys - [xpath]
          subpaths = keys.select{ |k| k.start_with?(xpath) }
          subpaths.each{ |p| ph[:subgroups] << p } if !subpaths.empty? && !ph[:parent].empty?
        end

        # populate is_group
        h.each do |xpath, ph|
          ct = ph[:mappings].size
          v = ph[:mappings].map{ |m| m[:in_repeating_group] }.uniq
          ph[:is_group] = true if v == ['y']
          if v.size > 1
            puts "WARNING: #{xpath} has fields with different :in_repeating_group values (#{v}). Defaulting to treating NOT as a group"
          end
          ph[:is_group] = true if ct == 1 && v == ['as part of larger repeating group'] && ph[:mappings][0][:repeats] == 'y'
        end

        # populate is_subgroup
        subgroups = []
        h.each{ |k, v| subgroups << v[:subgroups] }
        subgroups = subgroups.flatten.uniq
        h.keys.each{ |k| h[k][:is_subgroup] = true if subgroups.include?(k) }
        h
      end
    end
  end
end
