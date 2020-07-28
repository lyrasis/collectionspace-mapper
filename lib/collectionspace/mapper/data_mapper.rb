# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataMapper
      ::DataMapper = CollectionSpace::Mapper::DataMapper
      attr_reader :data, :handler, :mappings
      attr_accessor :doc, :map_result
      def initialize(data_hash, handler)
        @data = data_hash.transform_keys(&:downcase)
        @handler = handler
        @doc = @handler.blankdoc.clone
        @cache = @handler.cache

        merge_default_values
        @map_result = MapResult.new(data_hash: @data)

        # keep only mappings that apply to given data hash
        @mappings = @handler.mapper[:mappings].select{ |m| @data.keys.include?(m[:datacolumn].downcase) }
        
        # create xpaths for remaining mappings...
        xpaths = mappings.map{ |m| m[:fullpath] }.uniq
        # hash with xpath as key and xpath info hash from DataHandler as value
        xpaths = xpaths.map{ |xpath| [xpath, @handler.mapper[:xpath][xpath]] }.to_h

        # ...and send them to be split
        xpaths.each{ |xpath, hash| do_splits(xpath, hash) }
        # ...and do any transformations
        xpaths.each{ |xpath, hash| do_transforms(xpath, hash) }
        # ...and generate data quality warnings
        xpaths.each{ |xpath, hash| check_data_quality(xpath, hash) }
        # ...and send them to be mapped
        #xpaths.each{ |xpath| map(xpath) }

        
        #clean_doc
        #add_namespaces
      end

      def result
        @map_result.doc = @doc
        @map_result.warnings = @map_result.warnings.flatten
        @map_result.missing_terms = @map_result.missing_terms.flatten
        @map_result
      end

      private

      def check_data_quality(xpath, xphash)
        xformdata = @map_result.transformed_data
        xphash[:mappings].each do |mapping|
          data = xformdata[mapping[:datacolumn].downcase]
          return if data.nil?
          qc = DataQualityChecker.new(mapping, data)
          @map_result.warnings << qc.warnings unless qc.warnings.empty?
          @map_result.missing_terms << qc.missing_terms unless qc.missing_terms.empty?
        end
      end

      def do_splits(xpath, xphash)
        if xphash[:is_group] == false
          xphash[:mappings].each do |mapping|
            column = mapping[:datacolumn].downcase
            data = @data.fetch(column, nil)
            next if data.nil? || data.empty?
            @map_result.split_data[column] = mapping[:repeats] == 'y' ? SimpleSplitter.new(data).result : [data.strip]
          end
        elsif xphash[:is_group] == true && xphash[:is_subgroup] == false
          xphash[:mappings].each do |mapping|
            column = mapping[:datacolumn].downcase
            data = @data.fetch(column, nil)
            next if data.nil? || data.empty?
            @map_result.split_data[column] = SimpleSplitter.new(data).result
          end
        elsif xphash[:is_group] && xphash[:is_subgroup]
          xphash[:mappings].each do |mapping|
            column = mapping[:datacolumn].downcase
            data = @data.fetch(column, nil)
            next if data.nil? || data.empty?
            @map_result.split_data[column] = SubgroupSplitter.new(data).result
          end
        end
      end

      def do_transforms(xpath, xphash)
        splitdata = @map_result.split_data
        targetdata = @map_result.transformed_data
        xphash[:mappings].each do |mapping|
          column = mapping[:datacolumn].downcase
          data = splitdata.fetch(column, nil)
          next if data.nil? || data.empty?
          if mapping[:transforms].nil? || mapping[:transforms].empty?
            targetdata[column] = data
          else
            targetdata[column] = data.map do |d|
              if d.is_a?(String)
                ValueTransformer.new(d, mapping[:transforms], @cache).result
              else
                d.map{ |val| ValueTransformer.new(val, mapping[:transforms], @cache).result}
              end
            end
          end
        end
      end
      
      def clean_doc
        @doc.traverse{ |node| node.remove unless node.text.match?(/\S/m) }
      end
      
      def merge_default_values
        @handler.defaults.each do |f, val|
          if Mapper::CONFIG[:force_defaults]
            @data[f] = val
          else
            dataval = @data.fetch(f, nil)
            @data[f] = val if dataval.nil? || dataval.empty?
          end
        end
      end

      def map(xpath)
        xphash = @handler.mapper[:xpath][xpath]
        targetnode = @doc.xpath("//#{xpath}")[0]

        if xphash[:is_group] == false
          xphash[:mappings].each do |fm|
            col = fm[:datacolumn].downcase
            fn = fm[:fieldname]
            data = @data.fetch(col, nil)
            if data
              data.each do |val|
                unless fm[:transforms].nil? || fm[:transforms].empty?
                  t = ValueTransformer.new(val, fm[:transforms], @cache).result
                  @map_result.missing_terms << t[:missing]
                  val = t[:value]
                end
                child = Nokogiri::XML::Node.new(fn, @doc)
                child.content = val
                targetnode.add_child(child)
              end
            end
          end
        elsif xphash[:is_group] == true && xphash[:is_subgroup] == false
          pnode = targetnode.parent
          groupname = targetnode.name.dup
          targetnode.remove

          dhash = {}

          # handling multiple columns that get mapped to the same CSpace field
          # transforms have to be applied per-column
          # the resulting values then get joined so they can be include in one field
          xphash[:mappings].each do |fm|
            val = @data.fetch(fm[:datacolumn].downcase, nil)
            unless val.nil? || val.empty?
              unless fm[:transforms].empty? || fm[:transforms].nil?
                val = val.map{ |v| ValueTransformer.new(v, fm[:transforms], @cache).result }
                val.each{ |v| @map_result.missing_terms << v[:missing] }
                val = val.map{ |v| v[:value] }
              end
              
              if dhash.has_key?(fm[:fieldname])
                dhash[fm[:fieldname]] << val
              else
                dhash[fm[:fieldname]] = [val]
              end

              dhash[fm[:fieldname]] = dhash[fm[:fieldname]].flatten
            end
          end
          
          dhash = dhash.reject{ |k, v| v.nil? }.to_h
          dhash = dhash.reject{ |k, v| v.empty? }.to_h

          unless dhash.empty?
            val_ct = dhash.values.map{ |v| v.size }.uniq.sort.reverse
            # todo: warn?
            if val_ct.size > 1
              rhash = dhash.map{ |k, v| "#{k} (#{v.size} values)" }
              puts "WARNING: unequal number of values in record: #{rhash.join(' -- ')}"
            end
            
            max_ct = val_ct[0]
            max_ct.times do
              group = Nokogiri::XML::Node.new(groupname, @doc)
              pnode.add_child(group)
            end

            max_ct.times do |i|
              path = "//#{xpath}"
              parent = @doc.xpath(path)[i]
              dhash.each do |k, v|
                if v[i]
                  child = Nokogiri::XML::Node.new(k, @doc)
                  child.content = v[i]
                  parent.add_child(child)
                end
              end
            end
          end
        elsif xphash[:is_group] && xphash[:is_subgroup]
          dhash = {}
          parent_path = xphash[:parent]
          parent_set = @doc.xpath("//#{parent_path}")
          parent_size = parent_set.size
          subgroup_path = xphash[:mappings].first[:fullpath].gsub("#{xphash[:parent]}/", '').split('/')
          subgroup = subgroup_path.pop

          parent_set.each_with_index do |p, i|
            dhash[i] = { parent: p, data: {} }
          end

          fields = xphash[:mappings].map{ |m| m[:fieldname] }.uniq
          dhash.each do |group, h|
            fields.each{ |f| h[:data][f] = [] }
          end

          xphash[:mappings].each do |fm|
            val = @data.fetch(fm[:datacolumn].downcase, nil)
            unless val.nil? || val.empty?
              val = SubgroupSplitter.new(val).result
              #todo WARN?
              unless val.size == parent_size
                puts "#{fm[:fieldname]} size not equal to parent group (#{parent_path}) size"
              end

              val.each_with_index do |v, i|
                v = v.map{ |vx| ValueTransformer.new(vx, fm[:transforms], @cache).result }
                v.each{ |vx| @map_result.missing_terms << vx[:missing] }
                v = v.map{ |vx| vx[:value] }
                begin
                  dhash[i][:data][fm[:fieldname]] << v
                rescue
                  puts [fm[:fieldname]]
                end
              end
            end
          end

          dhash.each do |i, grp|
            grp[:data].transform_values!{ |v| v.flatten }
            
            target = parent_set[i]
            # create grouping-only fields in the hierarchy
            unless subgroup_path.empty?
              subgroup_path.each do |segment|
                child = Nokogiri::XML::Node.new(segment, @doc)
                target.add_child(child)
                target = child
              end
            end

            
            grp[:data] = grp[:data].reject{ |k, v| v.nil? }.to_h
            grp[:data] = grp[:data].reject{ |k, v| v.empty? }.to_h

            unless grp[:data].empty?
              val_ct = grp[:data].values.map{ |v| v.size }.uniq.sort.reverse
              # todo: warn?
              if val_ct.size > 1
                rhash = grp[:data].map{ |k, v| "#{k} (#{v.size} values)" }
                puts "WARNING: unequal number of values in record: #{rhash.join(' -- ')}"
              end

              max_ct = val_ct[0]
              max_ct.times do
                thisgroup = Nokogiri::XML::Node.new(subgroup, @doc)
                target.add_child(thisgroup)
              end

              max_ct.times do |sgi|
                parent = target.children[sgi]

                grp[:data].each do |sgf, sgv|
                  if sgv[sgi]
                    child = Nokogiri::XML::Node.new(sgf, @doc)
                    child.content = sgv[sgi]
                    parent.add_child(child)
                  end
                end
              end
            end
          end
        end
        @doc
      end
      
      def add_namespaces
        @doc.xpath('/*/*').each do |section|
          uri = @handler.mapper[:config][:ns_uri][section.name]
          section.add_namespace_definition('ns2', uri)
          section.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
          section.name = "ns2:#{section.name}"
        end
      end

    end
  end
end
