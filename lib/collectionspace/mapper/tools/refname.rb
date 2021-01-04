# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      class RefNameArgumentError < ArgumentError
        def initialize(msg='Arguments requires either :urn OR :source_type, :type, :subtype, :term, :cache values')
          super
        end
      end
      
      class RefName
        attr_reader :domain, :type, :subtype, :identifier, :display_name, :urn

        def initialize(args)
          term_args = %i[source_type type subtype term cache].sort
          urn_args = %i[urn]
          args_given = args.keys.sort

          if args_given == urn_args
            @urn = args[:urn]
            new_from_urn
          elsif args_given == term_args
            cache = args[:cache]
            @domain = cache.domain
            @type = args[:type]
            @subtype = args[:subtype]
            @display_name = args[:term]
            new_from_term(args[:source_type])
          else
            raise CollectionSpace::Mapper::Tools::RefNameArgumentError
          end
        end
        
        def new_from_term(source_type)
          @identifier = CollectionSpace::Mapper::Tools::Identifiers.short_identifier(@display_name, source_type)
          @urn = "urn:cspace:#{@domain}:#{@type}:name(#{@subtype}):item:name(#{@identifier})'#{@display_name}'"
        end

        def new_from_urn
          parts = @urn.match(/^urn:cspace:([^:]+):([^:]+):name\(([^\)]+)\):item:name\(([^\)]+)\)'/)
          @domain = parts[1]
          @type = parts[2]
          @subtype = parts[3]
          @identifier = parts[4]
          @display_name = @urn.match(/item:name\(.+\)'(.+)'$/)[1]
        end
      end
    end
  end
end
