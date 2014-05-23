#!/usr/bin/ruby

require 'rubygems'
require 'oauth'
require 'json'
require 'date'

# Static Variables
CONSUMERKEY    = "2ad67ad99cd58f2e0e8a8bb1c82d230c"
CONSUMERSECRET = "824cc12b1f8042e9d23675d4ed5f4cf9"
TOKEN          = "5554a8aeb5f7224f7dcaa1a735153c8c"
TOKENSECRET    = "c134285b81adafee53eca6987316c16c"

URL = "http://mage2.local/index.php/rest/default/V1/customerAccounts/"

if ARGV.count > 0
  numtoread = ARGV.shift.to_i
else
  numtoread = nil
end

@client = OAuth::Consumer.new CONSUMERKEY, CONSUMERSECRET, {:site=> "http://mage2.demo1" }
@token  = OAuth::AccessToken.new(@client, TOKEN, TOKENSECRET)

# Do the request
starttime = Time.now
if numtoread == nil then
  # figure out # of customers to read
  numtoread = 5
end

(1..numtoread).each do |x|
  url        = URL.to_s + x.to_s
  http_start = Time.now
  body       = @token.get(url,{'Content-Type' => 'application/json','Accept' => 'application/json'}).body
  http_end   = Time.now
  puts "Read 1 record in #{http_end - http_start} seconds, data #{body}"
end
endtime = Time.now
puts "Processed #{numtoread} read requests in #{endtime - starttime} seconds!"