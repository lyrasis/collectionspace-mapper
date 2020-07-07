# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # given a RecordMapper hash and a data hash, returns CollectionSpace XML document
    class DataMapper
      ::DataMapper = CollectionSpace::Mapper::DataMapper
      attr_reader :mapper, :cache, :blankdoc
      def initialize(record_mapper:, cache:)
        @mapper = record_mapper
        @mapper[:xpath] = xpath_hash
        @cache = cache
        @blankdoc = build_xml
        merge_config_transforms
      end

      # you can specify per-data-key transforms in your config.json
      # This method merges the config.json transforms into the RecordMapper field
      #   mappings for the appropriate fields
      def merge_config_transforms
        Mapper::CONFIG[:transforms].each do |datacol, x|
          target = @mapper[:mappings].select{ |m| m[:datacolumn] == datacol }
          unless target.empty?
          target = target.first
          target[:transforms] = target[:transforms].merge(x)
          end
        end
      end

      def map(data_hash)
        datafields = data_hash.keys.map{ |k| k.downcase }
        mappings = @mapper[:mappings].select{ |m| datafields.include?(m[:datacolumn].downcase) }
        xpaths = mappings.map{ |m| m[:fullpath] }.uniq
        xpmapper = XpathMapper.new(data_hash, self, @blankdoc.clone)
        xpaths.each{ |xpath| xpmapper.map(xpath) }
        xpmapper.doc.traverse{ |node| node.remove unless node.text.match?(/\S/m) }
        add_namespaces(xpmapper.doc)
      end

      def add_namespaces(doc)
        doc.xpath('/*/*').each do |section|
          uri = @mapper[:config][:ns_uri][section.name]
          section.add_namespace_definition('ns2', uri)
          section.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
          section.name = "ns2:#{section.name}"
        end
        doc
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
        @mapper[:mappings].each do |mapping|
          mapping[:fullpath] = ( [mapping[:namespace]] + mapping[:xpath] ).flatten.join('/')
          h[mapping[:fullpath]] = {parent: '', children: [], is_group: false, is_subgroup: false, subgroups: [], mappings: []}
        end
        
        @mapper[:mappings].each do |mapping|
          h[mapping[:fullpath]][:mappings] << mapping
        end
        
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
