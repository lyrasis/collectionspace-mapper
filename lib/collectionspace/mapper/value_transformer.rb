# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class ValueTransformer
      ::ValueTransformer = CollectionSpace::Mapper::ValueTransformer
      attr_reader :orig, :result
      def initialize(value, transforms, cache)
        @value = value
        @orig = @value.clone

        if @orig.empty? || @orig.nil?
          @result = ''
          else
        @transforms = transforms
        @cache = cache
        process_replacements if @transforms.keys.include?(:replacements)
        process_special if @transforms.keys.include?(:special)
        process_authority if @transforms.keys.include?(:authority)
        process_vocabulary if @transforms.keys.include?(:vocabulary)
        @result = @value
        end
      end

      def process_replacements
        @transforms[:replacements].each do |r|
          case r[:type]
          when :plain
            @value = @value.gsub(r[:find], r[:replace])
          when :regexp
            @value = @value.gsub(Regexp.new(r[:find]), r[:replace])
          end
        end
      end

      def process_special
        special = @transforms[:special]
        process_behrensmeyer if special.include?('behrensmeyer_translate')
      end
      
      def process_authority
        type = @transforms[:authority][0]
        subtype = @transforms[:authority][1]

        existing = @cache.get(type, subtype, @value)

        if existing
          @value = existing
        else
          #todo: WARN, put in queue for stub record creation?
          @value = Authorities.build_authority_urn(type, subtype, @value, @cache)
        end
      end

      def process_vocabulary
        vocabulary = @transforms[:vocabulary]
        
        existing = @cache.get('vocabularies', vocabulary, @value)
        if existing
          @value = existing
        else
          #todo: WARN, put in queue for stub record creation?
          #relationship between item:name values and display labels in vocabularies
          #  seems pretty random. Not sure how we automate this?
          @value = Vocabularies.build_vocabulary_urn(vocabulary, @value, @cache)
        end
      end

      def process_behrensmeyer
        lookup = {
          '0' => '0 - no cracking or flaking on bone surface',
          '1' => '1 - longitudinal and/or mosaic cracking present on surface',
          '2' => '2 - longitudinal cracks, exfoliation on surface',
          '3' => '3 - fibrous texture, extensive exfoliation',
          '4' => '4 - coarsely fibrous texture, splinters of bone loose on the surface, open cracks',
          '5' => '5 - bone crumbling in situ, large splinters'
        }
        @value = lookup.fetch(@value, @value)
      end
    end
  end
end
 
