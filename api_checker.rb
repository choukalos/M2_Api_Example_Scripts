#!/usr/bin/ruby

require 'rubygems'
require 'oauth'
require 'json'
require 'date'
require 'yaml'

APIURLS = {
  "customer"     => "/V1/customerAccounts/",
  "search"       => "/V1/customerAccounts/Search"
}
NUMBER = 50

# - ----- functions
def generate_string(length)
  string = ""
  while string.length < length
    string = ((('a'..'z').to_a)*3).shuffle[0,(rand(30).to_i)].join
  end
  return string
end

def generate_address
  firstname        = generate_string(6)
  lastname         = generate_string(6)
  street           = ["1 Amber Drive"]
  city             = "Austin"
  country_id       = "US"
  region           = { "region" => "Texas", "region_id" => 57, "region_code" => "TX" }
  postcode         = "77777"
  telephone        = "512-555-5555"
  default_billing  = true
  default_shipping = true
  { :firstname => firstname, :lastname => lastname, :street => street, :city => city, :country_id => country_id, :region => region, 
    :postcode => postcode, :telephone => telephone, :default_billing => default_billing, :default_shipping => default_shipping }
end



def generate_customer(address)
  address1  = address
  firstname = generate_string(3)
  lastname  = generate_string(4)
  email     = generate_string(4) + '@'.to_s + generate_string(4) + '.com'
  gender    = if (1 + rand(6)) > 3 then 0 else 1 end
  password  = "password123"
  customerdetail = { "firstname" => firstname, "lastname" => lastname, "email" => email, "gender" => gender }
  customer       = { "customerDetails" => { "customer" => customerdetail, "addresses" => [ address1 ]}, "password" => password }
  customer.to_json
end
# --------------------------------

if ARGV.count > 0
  yamlfile = ARGV.shift
else
  puts "api_checker.rb SYSTEMCONFIG"
end

# Config and setup tokens
config = YAML.load_file(yamlfile)
# setup token
client       = OAuth::Consumer.new config["consumerkey"], config["consumersecret"], {:site=> config["site"] }
token        = OAuth::AccessToken.new(client, config["token"], config["tokensecret"])
customer_ids = []

# Test Scenerio - create 50 customers; read 50 customers; delete 50 customers and time it
#
starttime = Time.now
url       = config["baseurl"].to_s + APIURLS["customer"].to_s
(1..NUMBER).each do |x|
  address      = generate_address
  customer     = generate_customer(address)
  http_start   = Time.now
  apicall      = token.post(url,customer,{'Content-Type' => 'application/json','Accpet' => 'application/json' })
  http_end     = Time.now
  customer_ids << JSON.parse(apicall.body)["id"].to_i
  puts "Create,#{apicall.code},#{apicall.msg},#{http_end - http_start} "
end
endtime = Time.now
puts "Processed #{NUMBER} create api calls in #{endtime - starttime} seconds or #{ (endtime - starttime) / NUMBER.to_f } seconds per call "  

#  Read calls  
starttime = Time.now
customer_ids.each do |x|
  url        = config["baseurl"].to_s + APIURLS["customer"].to_s + x.to_s
  http_start = Time.now
  apicall    = token.get(url,{'Content-Type' => 'application/json','Accpet' => 'application/json' })
  http_end   = Time.now
  puts "Read,#{apicall.code},#{apicall.msg},#{http_end - http_start} "
end
endtime = Time.now
puts "Processed #{NUMBER} read api calls in #{endtime - starttime} seconds or #{ (endtime - starttime) / NUMBER.to_f } seconds per call "  
  
# Delete Calls
starttime = Time.now
customer_ids.each do |x|
  url        = config["baseurl"].to_s + APIURLS["customer"].to_s + x.to_s
  http_start = Time.now
  apicall    = token.delete(url,{'Content-Type' => 'application/json','Accpet' => 'application/json' })
  http_end   = Time.now
  puts "Delete,#{apicall.code},#{apicall.msg},#{http_end - http_start} "
end
endtime = Time.now
puts "Processed #{NUMBER} delete api calls in #{endtime - starttime} seconds or #{ (endtime - starttime) / NUMBER.to_f } seconds per call "  
  

  
  
  
  