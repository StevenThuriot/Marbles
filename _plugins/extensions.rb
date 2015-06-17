module Jekyll
  module Filters
      
    def titleize(value)
        value.split(/(\W)/).map(&:capitalize).join
    end
      
  end
end