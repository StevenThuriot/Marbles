module Jekyll
    
    
  class CategoryIndex < Page

    def initialize(site, base, category, slug, posts, index, pageCount)
      @site = site
      @base = base
        @dir  = File.join((site.config['category_dir'] || 'categories'), slug)
      @name = 'index.html'      
        
      if index != 0          
          path = site.config['paginate_path']
          @name =  path.sub(':num', (index+1).to_s)
      end
     
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
      self.data['slug'] = slug
      self.data['category'] = category
      self.data['dir'] = dir
      self.data['subscriptionUrl'] = site.config['url'] + '/' + (site.config['category_dir'] || 'categories') + '/' + slug + '/rss/'
    end
  end


  class CategoryFeed < Page

    def initialize(site, base, category, slug, posts)
      @site = site
      @base = base
        @dir  = File.join((site.config['category_dir'] || 'categories'), slug)
      @name = 'rss/index.xml'
     
      self.process(@name)
      self.read_yaml(File.join(base, '_includes', 'custom'), 'category_feed.xml')
      self.data['slug'] = slug
      self.data['category'] = category
      self.data['dir'] = dir
      self.data['posts'] = posts
    end

  end


  class Site
      
    def write_category_index(category, slug, posts, index, pageCount, postCount)  
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
        
      index = CategoryIndex.new(self, self.source, category, slug, posts, index, pageCount)
      index.render(self.layouts, payload)
      index.write(self.dest)
        
      # Record that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index
    end

    def write_category_feed(category, slug, posts)  
        
      index = CategoryFeed.new(self, self.source, category, slug, posts)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
        
      # Record that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index
    end

    def write_category_indexes
      if self.layouts.key? 'category_index'      
          
          categoryHash = Hash.new
          
          self.posts.each do |post|
              (post.data['categories'] || ['Uncategorized']).each do |category|
            
                if !categoryHash.has_key?(category)
                    categoryHash[category] = Array.new
                end

                categoryHash[category].push post  
                  
              end      
          end
          
          categoryHash.each do |category, posts|              
              slug = category.
                        # Strip according to the mode
                        gsub(SLUGIFY_DEFAULT_REGEXP, '-').
                        # Remove leading/trailing hyphen
                        gsub(/^\-|\-$/i, '').
                        # Downcase
                        downcase
              
            self.write_category_feed(category, slug, posts)  
            
            if self.config['paginate']
                slicedPosts = posts.each_slice(5).to_a             
                slicedPosts.each_with_index do |slice, i|
                    self.write_category_index(category, slug, slice, i, slicedPosts.size, posts.size) 
                end
            else
                self.write_category_index(category, slug, posts, 0, posts.size, posts.size) 
            end
          end
      else
        throw "No 'category_index' layout found."
      end
    end

  end

  class GenerateCategory < Generator
    safe true
    priority :high

    def generate(site)
      site.write_category_indexes
    end

  end

    SLUGIFY_DEFAULT_REGEXP = Regexp.new('[^[:alnum:]]+').freeze
end

