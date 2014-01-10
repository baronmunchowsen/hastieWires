##
# 
##

require 'pathname'

module Jekyll
  
  class hastieWires_Page < Page
    # The last modified date to be used for web caching of this file.
    # Added for use by a sitemap generator
    attr_accessor :src_mtime
    
    # Initialize a new Page.
    #
    # site - The Site object.
    # base - The String path to the source.
    # dir  - The String path between the source and the file.
    # name - The String filename of the file.
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name + ".html"
      self.process(name + ".html")
      self.data = Hash.new
      self.data["layout"] = "default" #need to have a default layout
    end
    
    def to_liquid
      self.data.deep_merge({}) #need to do this to get the data to show up in the liquid template
    end
    
    def set_data(label, data)
      self.data[label] = data
    end
    
  end
  
  class Site
    def hastieWires_Do
      datafile = self.config['hastieWires_dataFile'] || 'sitemap'
      
      ##todo - check that datafile exists
      
      outputMsg("")
      outputMsg("--------> HastieWires Initiated")
      
      sm = self.data[datafile]
      sm.each_with_index do |page,index|
        _hastieWires_Do(page)
      end
      
      outputMsg("HastieWires Completed <--------")
    end
    
    def _hastieWires_Do(page, directory = "", parent = "")
      
      pagepath = ""
      if(page["path"] != nil) 
        pagepath = page["path"]
      end
      
      fn = pagepath
      if page.has_key?("submenu")
        fn = "index"
        directory = directory + pagepath + "/"
      end
      
      layout = "default"
      if page.has_key?("layout")
        layout = page["layout"]
      end
      
      # output a record
      # check whether the path exists or not
      pathcheck_html = Pathname.new(File.join(self.config['source'], directory, fn + '.html'))
      pathcheck_md = Pathname.new(File.join(self.config['source'], directory, fn + '.md'))
      
      overwrite_static = self.config['hastieWires_overwriteStatic'] || false
      
      if (pathcheck_html.exist? || pathcheck_md.exist?) && !overwrite_static
        #do nothing as the static file exists and the overwrite flag is set to false
        outputMsg("** skipped " + directory + fn + ".html -- file already existed in source directory")
      else
        index = hastieWires_Page.new(self, self.config['source'], directory, fn) 
    
        #alter the front matter
        #page.has_key?("layout") ? index.data["layout"] = page["layout"] : ''
        
        page.each do |key,value|
          index.set_data(key, value)
        end
        
        index.data.each do |key,value|
          index.set_data(key, value)
        end
        
        index.set_data('parent', parent)
        
        #write the file
        index.render(self.layouts, site_payload)
        index.write(self.dest)
        self.pages << index
        
        outputMsg(directory + fn + ".html created -- " + page["title"] + " :: " + layout)
      end
      
      
      if page.has_key?("submenu")
        page["submenu"].each do |subpage,i|
          hastieWires_Write(subpage, directory, page["path"])
        end
      end
      
    end
    
    def outputMsg(msg)
      if self.config["hastieWires_statusMsg"]
        puts msg
      end
    end

  end
  
  class HastieWires < Generator
    safe true
    
    def generate(site)
      site.hastieWires_Do
    end
  
  end
end