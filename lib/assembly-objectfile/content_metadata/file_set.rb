# frozen_string_literal: true

require 'active_support/core_ext/object/blank'

module Assembly
  class ContentMetadata
    # Represents a groups of related Files, such as a single master file and the derivatives
    class FileSet
      # @param [Boolean] dpg (false) is it a dpg bundle?
      # @param [Array<Assembly::ObjectFile>] resource_files
      # @param style
      def initialize(resource_files:, style:, dpg: false)
        @dpg = dpg
        @resource_files = resource_files
        @style = style
      end

      # objects in the special DPG folders are always type=object when we using :bundle=>:dpg
      # otherwise look at the style to determine the resource_type_description
      def resource_type_description
        @resource_type_description ||= special_dpg_resource? ? 'object' : resource_type_descriptions
      end

      def label_from_file(default:)
        resource_files.find { |obj| obj.label.present? }&.label || default
      end

      def files
        resource_files.map { |file| File.new(file: file) }
      end

      private

      attr_reader :dpg, :resource_files, :style

      def special_dpg_resource?
        return false unless dpg

        resource_files.collect { |obj| ContentMetadata.special_dpg_folder?(obj.dpg_folder) }.include?(true)
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def resource_type_descriptions
        # grab all of the file types within a resource into an array so we can decide what the resource type should be
        resource_file_types = resource_files.collect(&:object_type)
        resource_has_non_images = !(resource_file_types - [:image]).empty?

        case style
        when :simple_image, :map, :'webarchive-seed'
          'image'
        when :file
          'file'
        when :simple_book # in a simple book project, all resources are pages unless they are *all* non-images -- if so, switch the type to object
          resource_has_non_images && resource_file_types.include?(:image) == false ? 'object' : 'page'
        when :book_as_image # same as simple book, but all resources are images instead of pages, unless we need to switch them to object type
          resource_has_non_images && resource_file_types.include?(:image) == false ? 'object' : 'image'
        when :book_with_pdf # in book with PDF type, if we find a resource with *any* non images, switch it's type from book to object
          resource_has_non_images ? 'object' : 'page'
        when :document
          'document'
        when :'3d'
          resource_extensions = resource_files.collect(&:ext)
          if (resource_extensions & VALID_THREE_DIMENSION_EXTENTIONS).empty? # if this resource contains no known 3D file extensions, the resource type is file
            'file'
          else # otherwise the resource type is 3d
            '3d'
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
