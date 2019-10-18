# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

module Assembly
  class ContentMetadata
    # Types for the configuration
    module Types
      include Dry.Types()
    end

    # Represents a configuration for generating the content metadata
    class Config < Dry::Struct
      attribute :auto_labels, Types::Strict::Bool
      attribute :flatten_folder_structure, Types::Strict::Bool
      attribute :add_file_attributes, Types::Strict::Bool
      attribute :add_exif, Types::Strict::Bool
      attribute :file_attributes, Types::Strict::Hash
    end
  end
end
