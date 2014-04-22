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
NUMTOGEN       = 50

URL = "http://mage2.demo1/index.php/rest/default/V1/customerAccounts"

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

example_customer = {
  "customerdetail" => {
    "customer" => {"firstname" => "TestGuy", "lastname" => "Test", "email" => "testguy1@test.com", "gender" => 1 },
    "addresses" => [ { "street" => ["1 Test Street"], "city" => "Austin", "country_id" => "US", 
                       "region" => { "region" => "Texas", "region_id" => 57, "region_code" => "TX" },
                       "postcode" => "77777", "telephone" => "5555555555", "default_billing" => true, "default_shipping" => true} ]
  },
  "password" => "password123"
}

starttime = Time.now
(1..NUMTOGEN).each do  |x|
  url = URI.parse(URL)
  Net::HTTP.new(url.host, url.port).start do |http|
    req = Net::HTTP::Post.new(url.request_uri)
    req["Content-Type"] = "application/json"
    req["Accept"]       = "application/json"
    address             = generate_address
    req.body            = generate_customer(address)
#    req.body            = example_customer.to_json
    
    puts "Posting customer record to be created ... "
    puts req.body
    
    req["Content-Length"] = req.body.size
    sign_header(req)
    res = http.request(req)
    puts res.body
#    puts res.status
  end
end  
endtime = Time.now
puts "Processed #{NUMTOGEN} write requests in #{endtime - starttime} seconds!"