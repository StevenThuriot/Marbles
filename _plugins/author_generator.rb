module Jekyll
    
    
  class AuthorIndex < Page

    def initialize(site, base, slug, author, posts, index, pageCount)
      @site = site
      @base = base
      @dir  = File.join((site.config['author_dir'] || 'authors'), slug)
      @name = 'index.html'      
        
      if index != 0          
          path = site.config['paginate_path']
          @name =  path.sub(':num', (index+1).to_s)
      end
     
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'author_index.html')
      self.data['slug'] = slug
      self.data['author'] = author
      self.data['dir'] = dir
      self.data['title'] = "#{author['name']}"
      self.data['subscriptionUrl'] = site.config['url'] + '/' + (site.config['author_dir'] || 'authors') + '/' + slug + '/rss/'
    end
  end


  class AuthorFeed < Page

    def initialize(site, base, slug, author, posts)
      @site = site
      @base = base
      @dir  = File.join((site.config['author_dir'] || 'authors'), slug)
      @name = 'rss/index.xml'
     
      self.process(@name)
      self.read_yaml(File.join(base, '_includes', 'custom'), 'author_feed.xml')
      self.data['slug'] = slug
      self.data['author'] = author
      self.data['dir'] = dir
      self.data['title'] = "#{author['name']}"      
      self.data['posts'] = posts
    end

  end


  class Site
      
    def write_author_index(slug, author, posts, index, pageCount, postCount)  
      paginator = { "page" => index + 1,
                    "per_page" => self.config['paginate'],
                    "posts" => posts,
                    "total_posts" => postCount,
                    "total_pages" => pageCount }
      
      if  index != 0
          paginator['previous_page'] = index
          path = self.config['paginate_path']
          paginator['previous_page_path'] = path.sub(':num', (index).to_s)
      end
      
      if index != (pageCount - 1)
          paginator['next_page'] = index+2
          path = self.config['paginate_path']
          paginator['next_page_path'] = path.sub(':num', (index+2).to_s)
      end 
    
      payload =  site_payload
      payload['paginator'] = paginator
        
      index = AuthorIndex.new(self, self.source, slug, author, posts, index, pageCount)
      index.render(self.layouts, payload)
      index.write(self.dest)
        
      # Record that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index
    end

    def write_author_feed(slug, author, posts)  
        
      index = AuthorFeed.new(self, self.source, slug, author, posts)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
        
      # Record that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index
    end

    def write_author_indexes
      if self.layouts.key? 'author_index'      
          authorHash = Hash.new
          
          self.posts.each do |post|
            slug = post.data['author'] || self.config['author']
            
            if !authorHash.has_key?(slug)
                authorHash[slug] = Array.new
            end

            authorHash[slug].push post           
          end
          
          authorHash.each do |slug, posts|              
            author = self.data['authors'][slug]     
              
            self.write_author_feed(slug, author, posts)  
            
            if self.config['paginate']
                slicedPosts = posts.each_slice(5).to_a             
                slicedPosts.each_with_index do |slice, i|
                    self.write_author_index(slug, author, slice, i, slicedPosts.size, posts.size) 
                end
            else
                self.write_author_index(slug, author, posts, 0, posts.size, posts.size) 
            end
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

