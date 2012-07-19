require 'nokogiri'

module Assembly

  # This class generates content metadata for image files
  class ContentMetadata
    
      # Generates image content XML metadata for a repository object.
      # This method only produces content metadata for images
      # and does not depend on a specific folder structure.  Note that it is class level method.
      #
      # @param [Hash] a hash containg parameters needed to produce content metadata
      #   :druid = a string of druid of the repository object's druid id without 'druid:' prefix
      #   :style = a symbol containing the type of metadata to create, allowed values are :simple_image (default), :simple_book, :book_with_pdf
      #   :add_exif = a boolean to indicate if exif data should be added (mimetype, filesize, image height/width, etc.) to each file, defaults to false and is not required if project goes through assembly
      #   :add_file_attributes = a boolean to indicate if publish/preserve/shelve attributes should be added using defaults of supplied override by mime/type, defaults to false and is not required if project goes through assembly
      #   :file_attributes = an optional hash of file attributes by mimetype to use instead of defaults, only used if add_file_attributes is also true, e.g. {'image/tif'=>{:preserve=>'yes',:shelve=>'no',:publish=>'no'},'application/pdf'=>{:preserve=>'yes',:shelve=>'yes',:publish=>'yes'}}
      #   :objects = an array of Assembly::ObjectFile objects containing the list of files to add to content metadata
      #
      # Example:
      #    Assembly::Image.create_content_metadata(:druid=>'nx288wh8889',:style=>:simple_image,:objects=>object_files,:file_attributes=>false)
      def self.create_content_metadata(params={})

        druid=params[:druid]
        objects=params[:objects]

        return false if druid.nil? || objects.nil? || objects.size == 0

        style=params[:style] || :simple_image
        add_exif=params[:add_exif] || false
        add_file_attributes=params[:add_file_attributes] || false
        file_attributes=params[:file_attributes] || {}
        
        case style
          when :simple_image
            content_type_description = "image"
            resource_type_description = "image"
          when :simple_book
            content_type_description = "book"
            resource_type_description = "page"
          when :book_as_image
            content_type_description = "book"
            resource_type_description = "image"   
          else
            return false         
        end
          
        objects.each {|obj| return false unless obj.file_exists?}

        sequence = 0

        builder = Nokogiri::XML::Builder.new do |xml|
          xml.contentMetadata(:objectId => "#{druid}",:type => content_type_description) {
            objects.each do |obj|
              sequence += 1
              resource_id = "#{druid}_#{sequence}"
              # start a new resource element
              xml.resource(:id => resource_id,:sequence => sequence,:type => resource_type_description) {
                xml.label "#{resource_type_description.capitalize} #{sequence}"

                  mimetype = obj.mimetype
                  xml_file_params = {:id=> obj.path}
                  
                  if add_file_attributes
                    file_attributes_hash=file_attributes[mimetype] || Assembly::FILE_ATTRIBUTES[mimetype] || Assembly::FILE_ATTRIBUTES['default']
                    xml_file_params.merge!({
                      :preserve => file_attributes_hash[:preserve],
                      :publish  => file_attributes_hash[:publish],
                      :shelve   => file_attributes_hash[:shelve],
                    })
                  end
                  
                  xml_file_params.merge!({:mimetype => mimetype,:size => obj.filesize}) if add_exif
                  xml.file(xml_file_params) {
                    if add_exif # add exif info if the user requested it
                      xml.checksum(obj.sha1, :type => 'sha1')
                      xml.checksum(obj.md5, :type => 'md5')                                
                      xml.imageData(:height => obj.exif.imageheight, :width => obj.exif.imagewidth) if obj.image? # add image data for an image
                    elsif obj.provider_md5 || obj.provider_sha1 # if we did not add exif info, see if there are user supplied checksums to add
                      xml.checksum(obj.provider_sha1, :type => 'sha1') if obj.provider_sha1
                      xml.checksum(obj.provider_md5, :type => 'md5') if obj.provider_md5                                                    
                    end #add_exif
                  }

              }
            end # objects.each
          }
        end

        return builder.to_xml

      end
      
  end
  
end
