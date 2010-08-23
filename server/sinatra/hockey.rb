$LOAD_PATH << File.join(Dir.getwd, 'lib')
require 'rubygems'
require 'sinatra'
require "json"
require 'haml'
require 'app'

before do
  @base_host = "HOSTNAME"
  @base_url = "http://#{@base_host}/apps/"
  @directory = File.join(File.dirname(__FILE__),"public","apps")
end
  
get '/' do
  @apps = App.all_apps(@directory)
  haml :index
end

get '/:identifier' do
  @app = App.for_identifier(params[:identifier], @directory)
  content_type :json
  {:result => @app.version, :notes => @app.notes, :profile => File.ctime(File.join(@directory,@app.directory,@app.profile)), :title => @app.title, :subtitle => @app.subtitle }.to_json
end

get '/:identifier/:type' do
  @app = App.for_identifier(params[:identifier], @directory)
  if params[:type] == 'app'
    plist = Plist::parse_xml(File.join(@directory,@app.directory,@app.plist))
    plist["items"][0]["assets"][0]["url"] = "#{@base_url}#{@app.directory}/#{@app.ipa}"
    content_type :xml
    plist.to_plist
  elsif params[:type] == 'profile'
    send_file(File.join(@directory,@app.directory,@app.profile), :disposition => "attachment", :filename => @app.profile)
  end
end
