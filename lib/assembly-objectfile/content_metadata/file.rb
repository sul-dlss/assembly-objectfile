# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'

module Assembly
  class ContentMetadata
    # Represents a single File
    class File
      # @param [Symbol] bundle
      # @param [Assembly::ObjectFile] file
      # @param style
      def initialize(bundle: nil, file:, style: nil)
        @bundle = bundle
        @file = file
        @style = style
      end

      delegate :sha1, :md5, :provider_md5, :provider_sha1, :mimetype, :filesize, :image?, to: :file

      def file_id(common_path:, flatten_folder_structure:)
        # set file id attribute, first check the relative_path parameter on the object, and if it is set, just use that
        return file.relative_path if file.relative_path

        # if the relative_path attribute is not set, then use the path attribute and check to see if we need to remove the common part of the path
        file_id = common_path ? file.path.gsub(common_path, '') : file.path
        file_id = ::File.basename(file_id) if flatten_folder_structure
        file_id
      end

      def file_attributes(provided_file_attributes)
        file.file_attributes || provided_file_attributes[mimetype] || provided_file_attributes['default'] || Assembly::FILE_ATTRIBUTES[mimetype] || Assembly::FILE_ATTRIBUTES['default']
      end

      def image_data
        { height: file.exif.imageheight, width: file.exif.imagewidth }
      end

      private

      attr_reader :file
    end
  end
end
