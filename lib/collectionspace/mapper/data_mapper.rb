# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataMapper
      ::DataMapper = CollectionSpace::Mapper::DataMapper
      attr_reader :data, :mapper, :doc
      def initialize(data_hash, mapper, doc)
        @data = data_hash.transform_keys{ |k| k.downcase }
        @mapper = mapper
        @doc = doc.clone
        @cache = @mapper.cache
        @done = []
      end
      

      def map(xpath)
        return @doc if @done.include?(xpath)
        
        xphash = @mapper.mapper[:xpath][xpath]
        targetnode = @doc.xpath("//#{xpath}")[0]

        if xphash[:is_group] == false
          xphash[:mappings].each do |fm|
            col = fm[:datacolumn].downcase
            fn = fm[:fieldname]
            data = @data.fetch(col, nil)
            if data
              data = fm[:repeats] == 'y' ? SimpleSplitter.new(data).result : [data.strip]
              data.each do |val|
                unless fm[:transforms].nil? || fm[:transforms].empty?
                  val = ValueTransformer.new(val, fm[:transforms], @cache).result
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

          # concatenate multiple columns that get mapped to the same row
          xphash[:mappings].each do |fm|
            val = @data.fetch(fm[:datacolumn].downcase, nil)
            unless val.nil? || val.empty?
              val = SimpleSplitter.new(val).result
              unless fm[:transforms].empty? || fm[:transforms].nil?
                val = val.map{ |v| ValueTransformer.new(v, fm[:transforms], @cache).result }
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
        @done << xpath

        @doc
      end
    end
  end
end
