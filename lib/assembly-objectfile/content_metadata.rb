require 'nokogiri'

module Assembly
  SPECIAL_DPG_FOLDERS = %w[31 44 50].freeze # these special dpg folders will force any files contained in them into their own resources, regardless of filenaming convention
  # these are used when :bundle=>:dpg only

  DEPRECATED_STYLES = %i[book_with_pdf book_as_image].freeze

  # This class generates content metadata for image files
  class ContentMetadata
    # Generates image content XML metadata for a repository object.
    # This method only produces content metadata for images
    # and does not depend on a specific folder structure.  Note that it is class level method.
    #
    # @param [Hash] params a hash containg parameters needed to produce content metadata
    #   :druid = required - a string of druid of the repository object's druid id (with or without 'druid:' prefix)
    #   :objects = required - an array of Assembly::ObjectFile objects containing the list of files to add to content metadata
    #                NOTE: if you set the :bundle option to :prebundled, you will need to pass in an array of arrays, and not a flat array, as noted below
    #   :style = optional - a symbol containing the style of metadata to create, allowed values are
    #                 :simple_image (default), contentMetadata type="image", resource type="image"
    #                 :file, contentMetadata type="file", resource type="file"
    #                 :simple_book, contentMetadata type="book", resource type="page", but any resource which has file(s) other than an image, and also contains no images at all, will be resource type="object"
    #                 :book_with_pdf, contentMetadata type="book", resource type="page", but any resource which has any file(s) other than an image will be resource type="object" - NOTE: THIS IS DEPRECATED
    #                 :book_as_image, as simple_book, but with contentMetadata type="book", resource type="image" (same rule applies for resources with non images)  - NOTE: THIS IS DEPRECATED
    #                 :map, like simple_image, but with contentMetadata type="map", resource type="image"
    #   :bundle = optional - a symbol containing the method of bundling files into resources, allowed values are
    #                 :default = all files get their own resources (default)
    #                 :filename = files with the same filename but different extensions get bundled together in a single resource
    #                 :dpg = files representing the same image but of different mimetype that use the SULAIR DPG filenaming standard (00 vs 05) get bundled together in a single resource
    #                 :prebundlded = this option requires you to prebundled the files passed in as an array of arrays, indicating how files are bundlded into resources; this is the most flexible option since it gives you full control
    #   :add_exif = optional - a boolean to indicate if exif data should be added (mimetype, filesize, image height/width, etc.) to each file, defaults to false and is not required if project goes through assembly
    #   :add_file_attributes = optional - a boolean to indicate if publish/preserve/shelve/role attributes should be added using defaults or by supplied override by mime/type, defaults to false and is not required if project goes through assembly
    #   :file_attributes = optional - a hash of file attributes by mimetype to use instead of defaults, only used if add_file_attributes is also true,
    #             If a mimetype match is not found in your hash, the default is used (either your supplied default or the gems).
    #             e.g. {'default'=>{:preserve=>'yes',:shelve=>'yes',:publish=>'yes'},'image/tif'=>{:preserve=>'yes',:shelve=>'no',:publish=>'no'},'application/pdf'=>{:preserve=>'yes',:shelve=>'yes',:publish=>'yes'}}
    #   :include_root_xml = optional - a boolean to indicate if the contentMetadata returned includes a root <?xml version="1.0"?> tag, defaults to true
    #   :preserve_common_paths = optional - When creating the file "id" attribute, content metadata uses the "relative_path" attribute of the ObjectFile objects passed in.  If the "relative_path" attribute is not set,  the "path" attribute is used instead,
    #                   which includes a full path to the file. If the "preserve_common_paths" parameter is set to false or left off, then the common paths of all of the ObjectFile's passed in are removed from any "path" attributes.  This should turn full paths into
    #                   the relative paths that are required in content metadata file id nodes.  If you do not want this behavior, set "preserve_common_paths" to true.  The default is false.
    #   :flatten_folder_structure = optional - Will remove *all* folder structure when genearting file IDs (e.g. DPG subfolders like '00','05' will be removed) when generating file IDs.  This is useful if the folder structure is flattened when staging files (like for DPG).
    #                                             The default is false.  If set to true, will override the "preserve_common_paths" parameter.
    #   :auto_labels = optional - Will add automated resource labels (e.g. "File 1") when labels are not provided by the user.  The default is true.
    # Example:
    #    Assembly::ContentMetadata.create_content_metadata(:druid=>'druid:nx288wh8889',:style=>:simple_image,:objects=>object_files,:add_file_attributes=>false)
    def self.create_content_metadata(params = {})
      druid = params[:druid]
      objects = params[:objects]

      raise 'No objects and/or druid supplied' if druid.nil? || objects.nil?

      pid = druid.gsub('druid:', '') # remove druid prefix when creating IDs

      style = params[:style] || :simple_image
      bundle = params[:bundle] || :default
      add_exif = params[:add_exif] || false
      auto_labels = (params[:auto_labels].nil? ? true : params[:auto_labels])
      add_file_attributes = params[:add_file_attributes] || false
      file_attributes = params[:file_attributes] || {}
      preserve_common_paths = params[:preserve_common_paths] || false
      flatten_folder_structure = params[:flatten_folder_structure] || false
      include_root_xml = params[:include_root_xml]

      all_paths = []
      objects.flatten.each do |obj|
        raise "File '#{obj.path}' not found" unless obj.file_exists?

        all_paths << obj.path unless preserve_common_paths # collect all of the filenames into an array
      end

      common_path = Assembly::ObjectFile.common_path(all_paths) unless preserve_common_paths # find common paths to all files provided if needed

      # these are the valid strings for each type of document to be use contentMetadata type and resourceType
      content_type_descriptions = { file: 'file', image: 'image', book: 'book', map: 'map' }
      resource_type_descriptions = { object: 'object', file: 'file', image: 'image', book: 'page', map: 'image' }

      # global sequence for resource IDs
      sequence = 0

      # a counter to use when creating auto-labels for resources, with incremenets for each type
      resource_type_counters = Hash.new(0)

      # set the object level content type id
      case style
      when :simple_image
        content_type_description = content_type_descriptions[:image]
      when :file
        content_type_description = content_type_descriptions[:file]
      when :simple_book, :book_with_pdf, :book_as_image
        content_type_description = content_type_descriptions[:book]
      when :map
        content_type_description = content_type_descriptions[:map]
      else
        raise 'Supplied style not valid'
      end

      puts "WARNING - the style #{style} is now deprecated and should not be used." if DEPRECATED_STYLES.include? style

      # determine how many resources to create
      # setup an array of arrays, where the first array is the number of resources, and the second array is the object files containined in that resource
      case bundle
      when :default # one resource per object
        resources = objects.collect { |obj| [obj] }
      when :filename # one resource per distinct filename (excluding extension)
        # loop over distinct filenames, this determines how many resources we will have and
        # create one resource node per distinct filename, collecting the relevant objects with the distinct filename into that resource
        resources = []
        distinct_filenames = objects.collect(&:filename_without_ext).uniq # find all the unique filenames in the set of objects, leaving off extensions and base paths
        distinct_filenames.each { |distinct_filename| resources << objects.collect { |obj| obj if obj.filename_without_ext == distinct_filename }.compact }
      when :dpg # group by DPG filename
        # loop over distinct dpg base names, this determines how many resources we will have and
        # create one resource node per distinct dpg base name, collecting the relevant objects with the distinct names into that resource
        resources = []
        distinct_filenames = objects.collect(&:dpg_basename).uniq # find all the unique DPG filenames in the set of objects
        distinct_filenames.each do |distinct_filename|
          resources << objects.collect { |obj| obj if obj.dpg_basename == distinct_filename && !is_special_dpg_folder?(obj.dpg_folder) }.compact
        end
        objects.each { |obj| resources << [obj] if is_special_dpg_folder?(obj.dpg_folder) } # certain subfolders require individual resources for files within them regardless of file-naming convention
      when :prebundled
        # if the user specifies this method, they will pass in an array of arrays, indicating resources, so we don't need to bundle in the gem
        resources = objects
      else
        raise 'Invalid bundle method'
      end

      resources.delete([]) # delete any empty elements

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.contentMetadata(objectId: druid.to_s, type: content_type_description) do
          resources.each do |resource_files| # iterate over all the resources
            # start a new resource element
            sequence += 1
            resource_id = "#{pid}_#{sequence}"

            # grab all of the file types within a resource into an array so we can decide what the resource type should be
            resource_file_types = resource_files.collect(&:object_type)
            resource_has_non_images = !(resource_file_types - [:image]).empty?
            resource_from_special_dpg_folder = resource_files.collect { |obj| is_special_dpg_folder?(obj.dpg_folder) }.uniq

            if bundle == :dpg && resource_from_special_dpg_folder.include?(true) # objects in the special DPG folders are always type=object when we using :bundle=>:dpg
              resource_type_description = resource_type_descriptions[:object]
            else # otherwise look at the style to determine the resource_type_description
              case style
              when :simple_image
                resource_type_description = resource_type_descriptions[:image]
              when :file
                resource_type_description = resource_type_descriptions[:file]
              when :simple_book # in a simple book project, all resources are pages unless they are *all* non-images -- if so, switch the type to object
                resource_type_description = resource_has_non_images && resource_file_types.include?(:image) == false ? resource_type_descriptions[:object] : resource_type_descriptions[:book]
              when :book_as_image # same as simple book, but all resources are images instead of pages, unless we need to switch them to object type
                resource_type_description = resource_has_non_images && resource_file_types.include?(:image) == false ? resource_type_descriptions[:object] : resource_type_descriptions[:image]
              when :book_with_pdf # in book with PDF type, if we find a resource with *any* non images, switch it's type from book to object
                resource_type_description = resource_has_non_images ? resource_type_descriptions[:object] : resource_type_descriptions[:book]
              when :map
                resource_type_description = resource_type_descriptions[:map]
               end
            end

            resource_type_counters[resource_type_description.to_sym] += 1 # each resource type description gets its own incrementing counter

            xml.resource(id: resource_id, sequence: sequence, type: resource_type_description) do
              # create a generic resource label if needed
              resource_label = (auto_labels == true ? "#{resource_type_description.capitalize} #{resource_type_counters[resource_type_description.to_sym]}" : '')

              # but if one of the files has a label, use it instead
              resource_files.each { |obj| resource_label = obj.label unless obj.label.nil? || obj.label.empty? }

              xml.label(resource_label) unless resource_label.empty?

              resource_files.each do |obj| # iterate over all the files in a resource
                mimetype = obj.mimetype if add_file_attributes || add_exif # we only need to compute the mimetype if we are adding file attributes or exif info, otherwise skip it for performance reasons

                # set file id attribute, first check the relative_path parameter on the object, and if it is set, just use that
                if obj.relative_path
                  file_id = obj.relative_path
                else
                  # if the relative_path attribute is not set, then use the path attribute and check to see if we need to remove the common part of the path
                  file_id = preserve_common_paths ? obj.path : obj.path.gsub(common_path, '')
                  file_id = File.basename(file_id) if flatten_folder_structure
                end

                xml_file_params = { id: file_id }

                if add_file_attributes
                  file_attributes_hash = obj.file_attributes || file_attributes[mimetype] || file_attributes['default'] || Assembly::FILE_ATTRIBUTES[mimetype] || Assembly::FILE_ATTRIBUTES['default']
                  xml_file_params.merge!(
                    preserve: file_attributes_hash[:preserve],
                    publish: file_attributes_hash[:publish],
                    shelve: file_attributes_hash[:shelve],
                    role: file_attributes_hash[:role]
                  )
                  xml_file_params.reject! { |_k, v| v.nil? || v.empty? }
                end

                if add_exif
                  xml_file_params[:mimetype] = mimetype
                  xml_file_params[:size] = obj.filesize
                end
                xml.file(xml_file_params) do
                  if add_exif # add exif info if the user requested it
                    xml.checksum(obj.sha1, type: 'sha1')
                    xml.checksum(obj.md5, type: 'md5')
                    xml.imageData(height: obj.exif.imageheight, width: obj.exif.imagewidth) if obj.image? # add image data for an image
                  elsif obj.provider_md5 || obj.provider_sha1 # if we did not add exif info, see if there are user supplied checksums to add
                    xml.checksum(obj.provider_sha1, type: 'sha1') if obj.provider_sha1
                    xml.checksum(obj.provider_md5, type: 'md5') if obj.provider_md5
                  end # add_exif
                end
              end # end resource_files.each
            end
          end # resources.each
        end
      end

      result = if include_root_xml == false
                 builder.doc.root.to_xml
               else
                 builder.to_xml
               end

      result
    end # create_content_metadata

    def self.is_special_dpg_folder?(folder)
      SPECIAL_DPG_FOLDERS.include?(folder)
    end
  end # class
end # module
