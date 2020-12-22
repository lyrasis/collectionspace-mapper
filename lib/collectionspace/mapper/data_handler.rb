# frozen_string_literal: true

module CollectionSpace
  module Mapper

    # given a RecordMapper hash and a data hash, returns CollectionSpace XML document
    class DataHandler
      attr_reader :mapper, :client, :cache, :config, :blankdoc, :defaults, :validator,
        :is_authority, :known_fields

      def initialize(record_mapper, client, cache = nil,
                     config = CollectionSpace::Mapper::DEFAULT_CONFIG
                    )
        @mapper = CollectionSpace::Mapper::Tools::RecordMapper.convert(record_mapper)
        @is_authority = get_is_authority
        @client = client
        @config = get_config(config)
        @cache = cache.nil? ? get_cache : cache
        @response_mode = @config[:response_mode]
        add_short_id_mapping if @is_authority
        @known_fields = @mapper[:mappings].map{ |m| m[:datacolumn] }.map(&:downcase)
        @mapper[:xpath] = xpath_hash
        @blankdoc = build_xml
        @defaults = @config[:default_values] ? @config[:default_values].transform_keys(&:downcase) : {}
        merge_config_transforms
        @validator = CollectionSpace::Mapper::DataValidator.new(@mapper, @cache)
      end

      def process(data)
        response = CollectionSpace::Mapper::setup_data(data)
        if response.valid?
          prepper = CollectionSpace::Mapper::DataPrepper.new(response, self)
          prepper.prep
          mapper = CollectionSpace::Mapper::DataMapper.new(prepper.response, self, prepper.xphash)
          @response_mode == 'normal' ? mapper.response.normal : mapper.response
        else
          response
        end
      end

      def check_fields(data)
        data_fields = data.keys.map(&:downcase)
        unknown = data_fields - known_fields
        known = data_fields - unknown
        { known_fields: known, unknown_fields: unknown }
      end
      
      def validate(data)
        @validator.validate(data)
      end

      def prep(data)
        response = CollectionSpace::Mapper::setup_data(data)
        if response.valid?
          prepper = CollectionSpace::Mapper::DataPrepper.new(response, self)
          prepper.split_data
          prepper.transform_data
          prepper.check_data
          prepper.combine_data_fields
          prepper.response
        else
          response
        end
      end
      
      def map(response, xphash)
        mapper = CollectionSpace::Mapper::DataMapper.new(response, self, xphash)
        @response_mode == 'normal' ? mapper.response.normal : mapper.response
      end

      private

      def get_config(config)
        config_object = CollectionSpace::Mapper::Tools::Config.new(config)
        config_object.hash
      end

      def get_cache
        config = {
          domain: @client.domain,
          error_if_not_found: false,
          lifetime: 5 * 60,
          search_delay: 5 * 60,
          search_enabled: true
        }
        # search for authority records by display name, not short ID
        config[:search_identifiers] = @is_authority ? false : true
        CollectionSpace::RefCache.new(config: config, client: @client)
      end
      
      def add_short_id_mapping
        namespaces = @mapper[:mappings].map{ |m| m[:namespace]}.uniq
        this_ns = namespaces.first{ |ns| ns.end_with?('_common') }
        @mapper[:mappings] << {
          fieldname: 'shortIdentifier',
          namespace: this_ns,
          data_type: 'string',
          xpath: [],
          required: 'not in input data',
          repeats: 'n',
          in_repeating_group: 'n/a',
          datacolumn: 'shortIdentifier'
        }
      end

      def get_is_authority
        service_type = @mapper[:config][:service_type]
        service_type == 'authority' ? true : false
      end

      # you can specify per-data-key transforms in your config.json
      # This method merges the config.json transforms into the CollectionSpace::Mapper::RecordMapper field
      #   mappings for the appropriate fields
      def merge_config_transforms
        return unless @config[:transforms]
        @config[:transforms].transform_keys!(&:downcase)
        @config[:transforms].each do |datacol, x|
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
            mapping[:datacolumn] = mapping[:datacolumn].downcase
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
