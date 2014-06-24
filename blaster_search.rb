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
# 
NUMTOGEN       = 1
PERPAGE        = 20
PAGE           = 1

URL = "http://mage2.dev/index.php/rest/default/V1/customerAccounts/Search"

@client = OAuth::Consumer.new CONSUMERKEY, CONSUMERSECRET, {:site=> "http://mage2.dev" }
@token  = OAuth::AccessToken.new(@client, TOKEN, TOKENSECRET)

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
                            "value" => "2014-04-20",
                            "condition_type" => "gt"
                        }
                    ]
                }
             ],
            "current_page" => PAGE,
            "page_size" => PERPAGE
        }
}
# Check for update on timestamp
searchquery2 = {
  "searchCriteria" => {
    "filterGroups" => [
      {
        "filters" => [
          {
            "field" => "updated_at",
            "value" => "2014-06-23 20:11:40 ",
            "condition_type" => "gt"
          }
        ]
      }
    ],
    "current_page" => PAGE,
    "page_size"    => PERPAGE
  }
  
  
}

starttime = Time.now
(1..NUMTOGEN).each do  |x|
  url = URL.to_s
  puts @token.put(url,searchquery2.to_json,{'Content-Type' => 'application/json','Accept' => 'application/json'}).body
end  
endtime = Time.now
puts "Processed #{NUMTOGEN} search requests in #{endtime - starttime} seconds!"