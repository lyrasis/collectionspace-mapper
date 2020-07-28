# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class ValueTransformer
      ::ValueTransformer = CollectionSpace::Mapper::ValueTransformer
      attr_reader :orig, :result
      def initialize(value, transforms, cache)
        @value = value
        @orig = @value.clone

        @transforms = transforms
        @cache = cache
        @missing = {}
        process_replacements if @transforms.keys.include?(:replacements)
        process_special if @transforms.keys.include?(:special)
        process_authority if @transforms.keys.include?(:authority)
        process_vocabulary if @transforms.keys.include?(:vocabulary)
        @result = @value
      end

      def process_replacements
        return if @value.empty?
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
        process_boolean if special.include?('boolean')
        unless @value.empty?
          @value = @value.downcase if special.include?('downcase_value')
          process_behrensmeyer if special.include?('behrensmeyer_translate')
        end
      end
      
      def process_authority
        return if @value.empty?
        type = @transforms[:authority][0]
        subtype = @transforms[:authority][1]

        existing = @cache.get(type, subtype, @value)

        if existing
          @value = existing
        else
          # @missing = {
          #   category: :authority,
          #   type: type,
          #   subtype: subtype,
          #   value: @value
          # }
        end
      end

      def process_vocabulary
        return if @value.empty?
        vocabulary = @transforms[:vocabulary]
        
        existing = @cache.get('vocabularies', vocabulary, @value)
        if existing
          @value = existing
        else
          # @missing =  {
          #   category: :vocabulary,
          #   type: 'vocabularies',
          #   subtype: vocabulary,
          #   value: @value
          # }
        end
      end

      def process_boolean
        if @value.empty?
          @value = 'false'
        else
          case @value.downcase
          when 'true'
            @value = 'true'
          when 'false'
            @value = 'false'
          when ''
            @value = 'false'
          when 'yes'
            @value = 'true'
          when 'no'
            @value = 'false'
          when 'y'
            @value = 'true'
          when 'n'
            @value = 'false'
          when 't'
            @value = 'true'
          when 'f'
            @value = 'false'
          else
            #          Rails.logger.warn("#{value} cannot be converted to boolean in FIELD/ROW. Defaulting to false")
            @value = 'false'
          end
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
 
