# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML document
    class DataHandler
      ::DataHandler = CollectionSpace::Mapper::DataHandler
      attr_reader :mapper, :client, :cache, :config, :blankdoc, :defaults, :validator,
        :is_authority

      def initialize(record_mapper:, client:, cache:,
                     config: Mapper::DEFAULT_CONFIG
                    )
        @mapper = RecordMapper.convert(record_mapper)
        @client = client
        @cache = cache
        @config = get_config(config)
        @response_mode = get_response_mode
        @is_authority = get_is_authority
        add_short_id_mapping if @is_authority
        @mapper[:xpath] = xpath_hash
        
        @blankdoc = build_xml
        @defaults = @config[:default_values] ? @config[:default_values].transform_keys(&:downcase) : {}
        merge_config_transforms
        @validator = DataValidator.new(@mapper, @cache)
      end

      def process(data_hash)
        prepper = DataPrepper.new(data_hash, self)
        prepper.split_data
        prepper.transform_data
        prepper.check_data
        prepper.combine_data_fields

        mapper = DataMapper.new(prepper.response, self, prepper.xphash)
        mapper.response
      end
      
      def validate(data_hash, response = nil)
        @validator.validate(data_hash, response)
      end

      def prep(data_hash)
        prepper = DataPrepper.new(data_hash, self)
        prepper.split_data
        prepper.transform_data
        prepper.check_data
        prepper.combine_data_fields
        prepper.response
      end
      
      def map(response, xphash)
        datamapper = DataMapper.new(response, self, xphash)
        datamapper.response
      end

      private

      def get_config(config)
        config_object = Config.new(config)
        config_object.validate
        config_object.hash
      end

      def get_response_mode
      end
      
      def add_short_id_mapping
        namespaces = @mapper[:mappings].map{ |m| m[:namespace]}.uniq
        this_ns = namespaces.first{ |ns| ns.end_with?('_common') }
        @mapper[:mappings] << {
          fieldname: 'shortIdentifier',
          namespace: this_ns,
          data_type: 'string',
          xpath: [],
          required: 'y',
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
      # This method merges the config.json transforms into the RecordMapper field
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
