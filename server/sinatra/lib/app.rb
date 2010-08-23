require 'plist'

class App
  attr_accessor :title
  attr_accessor :subtitle
  attr_accessor :version
  attr_accessor :profile
  attr_accessor :profile_updated
  attr_accessor :directory
  attr_accessor :notes
  attr_accessor :plist
  attr_accessor :ipa

  TYPE_APP = 'app'
  TYPE_PROFILE = 'profile'
  
  def self.all_apps(directory)
    apps = []
    Dir.foreach(directory) do |item|
      if item != '.' && item != '..' && File.directory?(File.join(directory,item)) && !File.exists?(File.join(directory,item,'private'))
        app = App.new
        app.parse_app_dir(File.join(directory,item))
        if app.ipa && app.plist && app.profile
          app.directory = item
          app.parse_plist(directory)
          apps << app
        end
      end
    end
    return apps
  end
  
  def self.for_identifier(identifier, directory)
    if File.directory?(File.join(directory,identifier))
      app = App.new
      app.parse_app_dir(File.join(directory,identifier))
      if app.ipa && app.plist && app.profile
        app.directory = identifier
        app.parse_plist(directory)
      end
      return app
    end
    return nil
  end

  def parse_app_dir(directory)
    Dir.foreach(directory) do |file|
      if file =~ /.*\.plist$/
        self.plist = file
      elsif file =~ /.*\.ipa$/
        self.ipa = file
      elsif file =~ /.*\.mobileprovision$/
        self.profile = file
        self.profile_updated = File.ctime(File.join(directory,file))
      elsif file =~ /.*\.html$/
        f = File.open(File.join(directory,file))
        self.notes = f.gets
      end
    end    
  end
  
  def parse_plist(directory)
    plist = Plist::parse_xml(File.join(directory,self.directory,self.plist))
    self.title = plist["items"][0]["metadata"]["title"]
    self.subtitle = plist["items"][0]["metadata"]["subtitle"]
    self.version = plist["items"][0]["metadata"]["bundle-version"]
  end
  
end