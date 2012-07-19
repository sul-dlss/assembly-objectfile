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
      #   :add_exif = a boolean to indicate if exif data should be added (mimetype, filesize, image height/width, etc.), defaults to false and is not required if project goes through assembly
      #   :files = an array of arrays containing the list of files to add to content metadata, grouped according to resources
      #
      # Example:
      #    Assembly::Image.create_content_metadata(:druid=>'nx288wh8889',:style=>:image,:files=>
      #      [ ['foo.tif', 'foo.jp2'], ['bar.tif', 'bar.jp2'] ]
      #    )
      def self.create_content_metadata(params={})

        druid=params[:druid]
        file_sets=params[:file_sets]

        return false if druid.nil? || file_sets.nil?

        style=params[:style] || :simple_image
        add_exif=params[:add_exif] || false
        
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
          
        file_sets.flatten.each {|file| return false if !File.exists?(file)}

        sequence = 0

        builder = Nokogiri::XML::Builder.new do |xml|
          xml.contentMetadata(:objectId => "#{druid}",:type => content_type_description) {
            file_sets.each do |file_set|
              sequence += 1
              resource_id = "#{druid}_#{sequence}"
              # start a new resource element
              xml.resource(:id => resource_id,:sequence => sequence,:type => resource_type_description) {
                xml.label "#{resource_type_description.capitalize} #{sequence}"
                file_set.each do |filename|
                  obj=Assembly::ObjectFile.new(filename)
                  id       = filename
                  xml_file_params = {
                    :id       => id
                  }
                  if add_exif
                    mimetype = obj.mimetype
                    size     = obj.filesize
                    width    = obj.exif.imagewidth
                    height   = obj.exif.imageheight                
                    file_attributes=Assembly::FILE_ATTRIBUTES[mimetype] || Assembly::FILE_ATTRIBUTES['default']
                    # add a new file element to the XML for this file
                    xml_file_params.merge!({
                      :mimetype => mimetype,
                      :preserve => file_attributes[:preserve],
                      :publish  => file_attributes[:publish],
                      :shelve   => file_attributes[:shelve],
                      :size     => size
                    })
                    
                    if obj.image? # add image data for an image
                      xml.file(xml_file_params) {
                        xml.imageData(:height => height, :width => width)
                        xml.checksum obj.sha1, :type => 'sha1'
                        xml.checksum obj.md5, :type => 'md5'
                      }
                   else
                     xml.file(xml_file_params) {
                       xml.checksum obj.sha1, :type => 'sha1'
                       xml.checksum obj.md5, :type => 'md5'
                     }                     
                   end                   
                  else
                    xml.file(xml_file_params)                    
                  end # add_exif
                end # file_set.each
              }
            end # file_sets.each
          }
        end

        return builder.to_xml

      end

  end
  
end
