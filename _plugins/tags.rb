module Jekyll
  class AbsoluteUrlTag < Liquid::Tag
    @markup = nil

    def initialize(tag_name, markup, tokens)
      #strip leading and trailing spaces
      @markup = markup.strip
      super
    end

    def render(context)
      if @markup.empty?
        return "Error processing input, expected syntax: {% absolute [filename] %}"
      end

      #render the markup
      rawPath = Liquid::Template.parse(@markup).render context

      #strip leading and trailing quotes
      path = rawPath.gsub(/^("|')|("|')$/, '')

      #fix double slashes
      "//" + "#{context.registers[:site].config['url']}/#{path}".gsub(/.*?:\/\//, '').gsub(/\/{2,}/, '/').strip
    end
  end

  class CategorySlugTag < Liquid::Tag
    @markup = nil

    def initialize(tag_name, markup, tokens)
      #strip leading and trailing spaces
      @markup = markup.strip
      super
    end

    def render(context)
      if @markup.empty?
        return "Error processing input, expected syntax: {% absolute [filename] %}"
      end

      #render the markup
      rawSlug = Liquid::Template.parse(@markup).render context

      #strip leading and trailing quotes
      slug = rawSlug.gsub(/^("|')|("|')$/, '').to_s.strip
        
      #Resolve category
      category = context.registers[:site].data['tags'][slug]
      if category && category.has_key?("title")
          "#{category["title"]}"
      else
          slug = slug.split(/(\W)/).map(&:capitalize).join
          "#{slug}"
      end
    end
  end
end

Liquid::Template.register_tag('absolute', Jekyll::AbsoluteUrlTag)
Liquid::Template.register_tag('resolve_category', Jekyll::CategorySlugTag)