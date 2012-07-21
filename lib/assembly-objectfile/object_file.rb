module Assembly
  
  # This class contains generic methods to operate on any file.
  class ObjectFile

    include Assembly::ObjectFileable

    # Class level method that given an array of strings, return the longest common initial path.  Useful for removing a common path from a set of filenames when producing content metadata
    #
    # @param [Array] strings Array of filenames with paths to operate on
    # @return [String] Common part of path of filenames passed in
    #
    # Example:
    # puts Assembly::ObjectFile.common_prefix(['/Users/peter/00/test.tif','/Users/peter/05/test.jp2'])  # '/Users/peter/0'
    def self.common_path(strings)
      return nil if strings.size == 0
      n = 0
      x = strings.last
      n += 1 while strings.all? { |s| s[n] and s[n] == x[n] }
      common_prefix=x[0...n]
      if common_prefix[-1,1] != '/' # check if last element of the common string is the end of a directory
        return common_prefix.split('/')[0..-2].join('/') + "/"  # if not, split string along directories, and reject last one
      else
        return common_prefix # if it was, then return the common prefix directly
      end
    end
        
  end
  
end
