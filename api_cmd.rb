#!/usr/bin/ruby

require 'rubygems'
require 'oauth'
require 'json'
require 'date'
require 'yaml'

PERFORMANCE = true
CONTENTTYPE = {'Content-Type' => 'application/json','Accept' => 'application/json' }
# ----- Functions ---------



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
url     = config["baseurl"].to_s + command["url"].to_s
verb    = command["verb"].to_s
if command["req"] != nil then req = JSON.dump(command["req"]) else req = nil end

http_start = Time.now
case verb
  when /GET/i
    res = token.get(url,CONTENTTYPE)
  when /POST/i
    res = token.post(url,CONTENTTYPE,req)
  when /PUT/i
    res = token.put(url,CONTENTTYPE,req)
  when /DELETE/i
    res = token.delete(url,CONTENTTYPE)
  else
    puts "Do not understand verb #{verb} "
    exit
end
http_stop = Time.now
puts "#{verb},#{url},#{res.code},#{res.msg},#{http_stop - http_start} "
puts res.body  
  