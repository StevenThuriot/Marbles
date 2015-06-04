module Jekyll

  class AuthorIndex < Page

    def initialize(site, base, slug, author)
      @site = site
      @base = base
      @dir  = File.join((site.config['author_dir'] || 'authors'), slug)
      @name = 'index.html'
     
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'author_index.html')
      self.data['slug'] = slug
      self.data['author'] = author
      self.data['title'] = "#{author['name']}"
      
      posts = Array.new
      isMain = site.config['author'] == slug

      site.posts.each do |post|
          if post.data["author"]
             if isMain or post.data["author"] == slug
                 posts.push post
             end
          elsif isMain
              posts.push post
          end
      end
      
      self.data['posts'] = posts
    end

  end


  class Site

    def write_author_index(slug, author)      
      index = AuthorIndex.new(self, self.source, slug, author)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
      
      #TODO: Author feed
        
      # Record that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index
    end

    def write_author_indexes
      if self.layouts.key? 'author_index'      
        self.posts.each do |post|
            slug = post.data["author"] || self.config['author']
            author = self.data['authors'][slug]            
            self.write_author_index(slug, author)
        end
      else
        throw "No 'author_index' layout found."
      end
    end

  end

  class GenerateAuthor < Generator
    safe true
    priority :high

    def generate(site)
      site.write_author_indexes
    end

  end

end

