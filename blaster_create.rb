#!/usr/bin/ruby
# Some ruby gist on creating oauth signatures manually:  https://gist.github.com/cheenu/1469815 
# multipart oauth ruby examples http://wiki.openstreetmap.org/wiki/OAuth_ruby_examples 


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
NUMTOGEN       = 50

URL = "http://mage2.local/index.php/rest/default/V1/customerAccounts"

if ARGV.count > 0
  numtogen = ARGV.shift
end
if numtogen == nil
  numtogen = NUMTOGEN
end



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


# hack for not-multiform
starttime = Time.now
(1..numtogen).each do |x|
  address   = generate_address
  customer  = generate_customer(address)
  http_start = Time.now
  code       = @token.post(URL,customer,{'Content-Type' => 'application/json','Accpet' => 'application/json' }).code
  http_end   = Time.now
  puts " -- Create customer API call status: #{code} in #{http_end - http_start} seconds"
end
endtime = Time.now
puts "Processed #{numtogen} write requests in #{endtime - starttime} seconds!"