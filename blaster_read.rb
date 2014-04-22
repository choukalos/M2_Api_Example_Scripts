#!/usr/bin/ruby

require 'rubygems'
require 'oauth'
require 'json'
require 'date'

# Static Variables
CONSUMERKEY    = "fc6c444e70e64febd04f2b23a258f823"
CONSUMERSECRET = "47e985772ef6adcf3885478e1ec58476"
TOKEN          = "9600cef01273dcafb3f4432cc986d1d4"
TOKENSECRET    = "4496c61d1f51d81bdbab9769685c816a"

URL = "http://mage2.demo1/index.php/rest/default/V1/customerAccounts/"

@client = OAuth::Consumer.new CONSUMERKEY, CONSUMERSECRET, {:site=> "http://mage2.demo1" }
@token  = OAuth::AccessToken.new(@client, TOKEN, TOKENSECRET)

# Functions
def add_multipart_data(req,params)
  boundary = Time.now.to_i.to_s(16)
  req["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
  body = ""
  params.each do |key,value|
    esc_key = CGI.escape(key.to_s)
    body << "--#{boundary}#{CRLF}"
    if value.respond_to?(:read)
      body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(value.path)}\"#{CRLF}"
      body << "Content-Type: application/json#{CRLF*2}"
      body << value.read
    else
      body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF*2}#{value}"
    end
    body << CRLF
  end
  body << "--#{boundary}--#{CRLF*2}"
  req.body = body
  req["Content-Length"] = req.body.size
end

def sign_header(req)
  @client.sign!(req, @token)
end

# Do the request

starttime = Time.now
(1..5).each do  |x|
url       = URI.parse(URL.to_s + x.to_s)
  Net::HTTP.new(url.host, url.port).start do |http|
    req = Net::HTTP::Get.new(url.request_uri)
    req["Content-Type"] = "application/json"
    req["Accept"]       = "application/json"
#  add_multipart_data(req,:file=>file, :tags => 'hehehe')
    sign_header(req)
    res = http.request(req)
    puts res.body
  end
end  
endtime = Time.now
puts "Processed 5 read requests in #{endtime - starttime} seconds!"