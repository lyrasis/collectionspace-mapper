# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataMapper
      attr_reader :handler, :xphash
      attr_accessor :doc, :response
      def initialize(response, handler, xphash)
        @response = response
        @handler = handler
        @xphash = xphash
        
        @data = @response.combined_data
        @doc = @handler.blankdoc.clone
        @cache = @handler.cache
        
        @xphash.each{ |xpath, hash| map(xpath, hash) }
        clean_doc
        add_short_id if @handler.is_authority
        set_response_identifier
        add_namespaces
        @response.doc = @doc
      end

      private

      def set_response_identifier
        if @handler.mapper[:config][:service_type] == 'relation'
          set_relation_id
        else
          id_field = @handler.mapper[:config][:identifier_field]
          mapping = @handler.mapper[:mappings].select{ |m| m[:fieldname] == id_field }.first
          value = @doc.xpath("//#{mapping[:namespace]}/#{mapping[:fieldname]}").first.text
          @response.identifier = value
        end
      end

      def set_relation_id
        case @handler.mapper[:config][:object_name]
        when 'Object Hierarchy Relation'
          narrow = @response.orig_data['narrower_object_number']
          broad = @response.orig_data['broader_object_number']
          @response.identifier = "#{broad} > #{narrow}"
        end
      end
      
      def add_short_id
        term = @response.transformed_data['termdisplayname'][0]
        ns = @xphash.keys.map{ |k| k.sub(/^([^\/]+).*/, '\1') }
          .select{ |k| k.end_with?('_common') }
          .first
        targetnode = @doc.xpath("/document/#{ns}").first
        child = Nokogiri::XML::Node.new('shortIdentifier', @doc)
        child.content = CollectionSpace::Mapper::Tools::Identifiers.short_identifier(term, :authority)
        targetnode.add_child(child)
      end

      def map(xpath, xphash)
        thisdata = @data[xpath]
        targetnode = @doc.xpath("//#{xpath}")[0]
        xphash[:mappings] = xphash[:mappings].uniq{ |m| m[:fieldname] }
        if xphash[:is_group] == false
          simple_map(xpath, xphash, targetnode, thisdata)
        elsif xphash[:is_group] == true && xphash[:is_subgroup] == false
          map_group(xpath, xphash, targetnode, thisdata)
        elsif xphash[:is_group] == true && xphash[:is_subgroup] == true
          map_subgroup(xpath, xphash, targetnode, thisdata)
        end
      end
      
      def clean_doc
        @doc.traverse do |node|
          node.remove if node.text == '%NULLVALUE%'
          node.remove unless node.text.match?(/\S/m)
        end
      end
      
      def add_namespaces
        @doc.xpath('/*/*').each do |section|
          fetchuri = @handler.mapper.dig(:config, :ns_uri, section.name)
          uri = fetchuri.nil? ? 'http://no.uri.found' : fetchuri
          section.add_namespace_definition('ns2', uri)
          section.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
          section.name = "ns2:#{section.name}"
        end
      end

      def map_structured_date(groupname, hash)
        target = groupname
        hash.each do |fieldname, value|
          child = Nokogiri::XML::Node.new(fieldname, @doc)
          child.content = value
          target.add_child(child)
        end
      end
      
      def simple_map(xpath, xphash, targetnode, thisdata)
        xphash[:mappings].each do |fm|
          fn = fm[:fieldname]
          data = thisdata.fetch(fn, nil)
          if data
            data.each do |val|
              child = Nokogiri::XML::Node.new(fn, @doc)
              if val.is_a?(Hash)
                map_structured_date(child, val)
              else
                child.content = val
              end
              targetnode.add_child(child)
            end
          end
        end
      end
      
      def map_group(xpath, xphash, targetnode, thisdata)
        pnode = targetnode.parent
        groupname = targetnode.name.dup
        targetnode.remove

        val_ct = thisdata.values.map{ |v| v.size }.uniq.sort.reverse
        max_ct = val_ct[0]
        max_ct.times do
          group = Nokogiri::XML::Node.new(groupname, @doc)
          pnode.add_child(group)
        end

        max_ct.times do |i|
          path = "//#{xpath}"
          parent = @doc.xpath(path)[i]
          thisdata.each do |k, v|
            if v[i]
              child = Nokogiri::XML::Node.new(k, @doc)
              if v[i].is_a?(Hash)
                map_structured_date(child, v[i]) 
              else v[i]
                child.content = v[i]
              end
              parent.add_child(child)
            end
          end
        end
      end

      def even_subgroup_field_values?(data)
        data.values.map(&:flatten).map(&:length).uniq.length == 1 ? true : false
      end

      def add_uneven_subgroup_warning(parent_path:, intervening_path:, subgroup:)
        response.warnings << {
          category: :uneven_subgroup_field_values,
          field: nil,
          type: nil,
          subtype: nil,
          value: nil,
          message: "Fields in subgroup #{parent_path}/#{intervening_path.join('/')}/#{subgroup} have different numbers of values"
        }
      end

      def add_too_many_subgroups_warning(parent_path:, intervening_path:, subgroup:)
        response.warnings << {
          category: :subgroup_contains_data_for_nonexistent_groups,
          field: nil,
          type: nil,
          subtype: nil,
          value: nil,
          message: "Data for subgroup #{intervening_path.join('/')}/#{subgroup} is trying to map to more instances of parent group #{parent_path} than exist. Overflow subgroup values will be skipped. The usual cause of this is that you separated subgroup values that belong inside the same parent group with the repeating field delimiter (#{handler.config[:delimiter]}) instead of the subgroup delimiter (#{handler.config[:subgroup_delimiter]})"
        }
      end

      def group_accommodates_subgroup?(groupdata, subgroupdata)
        sg_max_length = subgroupdata.values.map(&:flatten).map(&:length).max
        sg_max_length <= groupdata.length ? true : false
      end
      
      def map_subgroup(xpath, xphash, targetnode, thisdata)
        parent_path = xphash[:parent]
        parent_set = @doc.xpath("//#{parent_path}")
        parent_size = parent_set.size
        subgroup_path = xphash[:mappings].first[:fullpath].gsub("#{xphash[:parent]}/", '').split('/')
        subgroup = subgroup_path.pop

        # create a hash of subgroup data split up and structured for mapping
        groups = {}
        # populated it with parent group for each subgroup, keyed by group index
        parent_set.each_with_index do |p, i|
          groups[i] = { parent: p, data: {} }
        end

        add_uneven_subgroup_warning(parent_path: parent_path,
                                    intervening_path: subgroup_path,
                                    subgroup: subgroup) unless even_subgroup_field_values?(thisdata)
        add_too_many_subgroups_warning(parent_path: parent_path,
                                    intervening_path: subgroup_path,
                                    subgroup: subgroup) unless group_accommodates_subgroup?(groups, thisdata)
        
        thisdata.each do |f, v|
          v.each_with_index do |val, i|
            next if groups[i].nil?
            groups[i][:data][f] = val
          end
        end
        
        # create grouping-only fields in the xml hierarchy for the subgroup
        groups.each do |i, grp|
          target = grp[:parent]
          unless subgroup_path.empty?
            subgroup_path.each do |segment|
              child = Nokogiri::XML::Node.new(segment, @doc)
              target.add_child(child)
              target = child
            end
          end
        end

        # create the subgroups
        val_ct = thisdata.values.map{ |g| g.map{ |sg| sg.size }.uniq.sort.reverse }.uniq.sort.reverse.flatten
        max_ct = val_ct[0]
        groups.each do |i, data|
          max_ct.times do
            target = @doc.xpath("//#{parent_path}/#{subgroup_path.join('/')}")
            target[i].add_child(Nokogiri::XML::Node.new(subgroup, @doc))
          end
        end

        groups.each do |gi, grphash|
          gxp = "//#{parent_path}"
          grp_target = @doc.xpath(gxp)[gi]
          txp = "#{subgroup_path.join('/')}/#{subgroup}"
          subgrouplist_target = grp_target.xpath(txp)
          grphash[:data].each do |field, data|
            data.each_with_index do |val, i|
              target = subgrouplist_target[i]
              child = Nokogiri::XML::Node.new(field, @doc)
              if val.is_a?(Hash)
                map_structured_date(child, val)
              else
                child.content = val
                target.add_child(child) if target
              end
            end
          end
        end
      end
    end
  end
end
