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

      config = context.registers[:site].config
      useScheme = config['useScheme'];
      
      url = config['url']
      if !useScheme
          url = url.sub(/^https?\:\/\//, '//')
      end
      
      
      #fix double slashes
      "#{url}#{config['baseurl']}#{path}".gsub(/([^:])\/\//, '\1/').strip
    end
  end  

  class RelativeUrlTag < Liquid::Tag
    @markup = nil

    def initialize(tag_name, markup, tokens)
      #strip leading and trailing spaces
      @markup = markup.strip
      super
    end

    def render(context)
      if @markup.empty?
          return "Error processing input, expected syntax: {% relative [filename] %}"
      end

      #render the markup
      rawPath = Liquid::Template.parse(@markup).render context

      #strip leading and trailing quotes
      path = rawPath.gsub(/^("|')|("|')$/, '')

      config = 
      #fix double slashes
      "#{context.registers[:site].config['baseurl']}#{path}".gsub(/.*?:\/\//, '').gsub(/\/{2,}/, '/').strip
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
          return "Error processing input, expected syntax: {% resolve_category [filename] %}"
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


  class TranslateTag < Liquid::Tag
    @markups = nil
    @sentence = nil

    def initialize(tag_name, text, tokens)
      first,*rest = text.split(/►/) #ascii 16
        
      @sentence = first.strip
      @markups = rest.map { |tag| tag.strip }
      super
    end

    def render(context)
      site = context.registers[:site]
      config = site.config
      language = config['language'].downcase        
      translationData = site.data['language']
      translate = translationData[language]
                
      sentence = translate[Liquid::Template.parse(@sentence).render(context).strip]
    
      if sentence.nil?
          raise "Error processing input, unknown sentence '#{@sentence}'..."
      end
        
      rendered = @markups.map { |markup| Liquid::Template.parse(markup).render(context).strip }
      
      sentence % rendered
    end
  end  
end

Liquid::Template.register_tag('relative', Jekyll::RelativeUrlTag)
Liquid::Template.register_tag('absolute', Jekyll::AbsoluteUrlTag)
Liquid::Template.register_tag('resolve_category', Jekyll::CategorySlugTag)
Liquid::Template.register_tag('translate', Jekyll::TranslateTag)