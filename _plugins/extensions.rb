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
      
  def expand_urls(input, url='', useScheme=true)
      url ||= '/'
      
      if !useScheme
          url = url.sub(/^https?\:\/\//, '//')
      end
      
    input.gsub /(\s+(href|src|poster)\s*=\s*["|']{1})(\/[^\/>]{1}[^\"'>]*)/ do
      $1+url+$3
    end
  end

  end
end