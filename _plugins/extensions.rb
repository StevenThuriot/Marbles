module Jekyll
  module Filters
      
    def titleize(value)
        value.split(/(\W)/).map(&:capitalize).join
    end  
      
    # Removes trailing forward slash from a string for easily appending url segments
    def strip_slash(input)
      if input =~ /(.+)\/$|^\/$/
        input = $1
      end
      input
    end
      
    def expand_urls(input, url='', scheme='')
      url ||= ''
      if scheme.to_s.empty?
          scheme = "//" 
      else
          scheme = scheme + "://" 
      end
      input.gsub /(\s+(href|src)\s*=\s*["|'](?!\/\/){1})(\/[^\"'>]*)/ do
        $1+scheme+url+$3
      end
    end

  end
end