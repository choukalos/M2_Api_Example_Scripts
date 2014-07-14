#!/usr/bin/ruby

require 'rubygems'
require 'oauth'
require 'json'
require 'date'
require 'yaml'

PERFORMANCE = true
CONTENTTYPE = {'Content-Type' => 'application/json', 'Accept' => 'application/json' }
# ----- Functions ---------
def call_api(token,url,verb,req)
  http_start = Time.now
  case verb
    when /GET/i
      res = token.get(url,CONTENTTYPE)
    when /POST/i
      res = token.post(url,req,CONTENTTYPE)
    when /PUT/i
      res = token.put(url,req,CONTENTTYPE)
    when /DELETE/i
      res = token.delete(url,CONTENTTYPE)
    else
      puts "Do not understand verb #{verb} "
      exit
  end
  http_stop = Time.now
  puts "#{verb},#{url},#{res.code},#{res.msg},#{http_stop - http_start} "
  puts res.body  
  return res.code
end
# ----- Main --------------

if ARGV.count > 1
  configfile  = ARGV.shift
  commandfile = ARGV.shift
else
  puts "api_cmd.rb CONFIG COMMAND"
  puts "  CONFIG  = YAML configuration file "
  puts "  COMMAND = YAML API command file  "
  exit
end

# Config and setup tokens
config = YAML.load_file(configfile)
# setup token
client = OAuth::Consumer.new config["consumerkey"], config["consumersecret"], {:site=> config["site"] }
token  = OAuth::AccessToken.new(client, config["token"], config["tokensecret"])
# Config and setup command
command = YAML.load_file(commandfile)
if command["calls"] != nil 
  # Loop through command file with multiple API calls
  api_start = Time.now
  api_calls = 0
  command["calls"].each do |cmd|
    url  = config["baseurl"].to_s + cmd["url"].to_s
    verb = cmd["verb"].to_s
    if cmd["req"]   != nil then req = JSON.dump(cmd["req"]) else req = nil end
    if cmd["param"] !=nil then  url += cmd["param"] end 
    rc = call_api(token,url,verb,req)
    api_calls += 1
  end  
  api_end = Time.now
  puts "Made #{api_calls} in #{api_end - api_start} seconds averaging #{(api_end - api_start)/(api_calls+1)} seconds/call "
else
  # single call command file
  url     = config["baseurl"].to_s + command["url"].to_s
  verb    = command["verb"].to_s
  if command["req"]   != nil then req = JSON.dump(command["req"]) else req = nil end
  if command["param"] !=nil then url += command["param"] end 
  call_api(token,url,verb,req)
end
  