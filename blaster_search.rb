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
# 
NUMTOGEN       = 1
PERPAGE        = 20
PAGE           = 1

URL = "http://mage2.demo1/index.php/rest/default/V1/customerAccounts/Search"

@client = OAuth::Consumer.new CONSUMERKEY, CONSUMERSECRET, {:site=> "http://mage2.demo1" }
@token  = OAuth::AccessToken.new(@client, TOKEN, TOKENSECRET)

# Functions
def sign_header(req)
  @client.sign!(req, @token)
end

# Do the request
searchquery = {
        "searchCriteria" => {
            "filterGroups" => [
                {
                    "filters" => [
                        {
                            "field" => "email",
                            "value" => "%test%",
                            "condition_type" => "like"
                        },
                        {
                            "field" => "updated_at",
                            "value" => "2014-04-21",
                            "condition_type" => "gt"
                        }
                    ]
                }
             ],
            "current_page" => PAGE,
            "page_size" => PERPAGE
        }
}

starttime = Time.now
(1..NUMTOGEN).each do  |x|
  url = URI.parse(URL)
  Net::HTTP.new(url.host, url.port).start do |http|
    req = Net::HTTP::Put.new(url.request_uri)
    req["Content-Type"] = "application/json"
    req["Accept"]       = "application/json"
    req.body            = searchquery.to_json
#    
#    puts "Posting customer search query ... "
#    puts req.body
#    
    req["Content-Length"] = req.body.size
    sign_header(req)
    res = http.request(req)
    puts res.body
#    puts res.status
  end
end  
endtime = Time.now
puts "Processed #{NUMTOGEN} search requests in #{endtime - starttime} seconds!"