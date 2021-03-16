# frozen_string_literal: true

module Assembly
  class ContentMetadata
    # Builds a nokogiri representation of the content metadata
    class NokogiriBuilder
      # @param [Array<Fileset>] filesets
      # @param [String] druid
      # @param [String] common_path
      # @param [Config] config
      def self.build(filesets:, druid:, common_path:, config:)
        # a counter to use when creating auto-labels for resources, with incremenets for each type
        resource_type_counters = Hash.new(0)
        pid = druid.gsub('druid:', '') # remove druid prefix when creating IDs

        Nokogiri::XML::Builder.new do |xml|
          xml.contentMetadata(objectId: druid.to_s, type: config.type) do
            filesets.each_with_index do |fileset, index| # iterate over all the resources
              # start a new resource element
              sequence = index + 1

              resource_type_counters[fileset.resource_type_description] += 1 # each resource type description gets its own incrementing counter

              xml.resource(id: "#{pid}_#{sequence}", sequence: sequence, type: fileset.resource_type_description) do
                # create a generic resource label if needed
                default_label = config.auto_labels ? "#{fileset.resource_type_description.capitalize} #{resource_type_counters[fileset.resource_type_description]}" : ''

                # but if one of the files has a label, use it instead
                resource_label = fileset.label_from_file(default: default_label)

                xml.label(resource_label) unless resource_label.empty?
                fileset.files.each do |obj| # iterate over all the files in a resource
                  xml_file_params = { id: obj.file_id(common_path: common_path, flatten_folder_structure: config.flatten_folder_structure) }
                  xml_file_params.merge!(obj.file_attributes(config.file_attributes)) if config.add_file_attributes
                  xml_file_params.merge!(mimetype: obj.mimetype, size: obj.filesize) if config.add_exif

                  xml.file(xml_file_params) do
                    if config.add_exif # add exif info if the user requested it
                      xml.checksum(obj.sha1, type: 'sha1')
                      xml.checksum(obj.md5, type: 'md5')
                      xml.imageData(obj.image_data) if obj.image? # add image data for an image
                    elsif obj.provider_md5 || obj.provider_sha1 # if we did not add exif info, see if there are user supplied checksums to add
                      xml.checksum(obj.provider_sha1, type: 'sha1') if obj.provider_sha1
                      xml.checksum(obj.provider_md5, type: 'md5') if obj.provider_md5
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
