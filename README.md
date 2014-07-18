Collection of simple scripts that use Magento M2 service APIs

API Path
- store BASE URL
- Add index.php
- then /rest for rest or /soap for soap
- then store code if setup or /default for the default store 
- then your versioned api's which can be see in the module's etc/webapi.xml file
- for my local demo site it would be http://mage2.demo1/index.php/rest/default/

Scripts
- api_checker.rb runs a short test cycle to see what ~ average api times are
- api_cmd.rb runs command files ( YAML ) to see response & average api times

Details on API_CMD script
- api_cmd.rb CONFIGURATION.yml command/COMMAND.yml
- where CONIGURATION.yml contains your tokens and base URL ( see default.yml for example )
- where COMMAND.yml contains url and verb with req being an optional object for put/post verbs
- command directory contains an example set of api uses
-- where CONIGURATION.yml contains your tokens and base URL ( see default.yml for example )
-- where COMMAND.yml contains url and verb with req being an optional object for put/post verbs
-- command directory contains an example set of api uses

To setup:
- you need to create an integration ( system -> extensions: Integration ) & authorize
- Copy the 4 tokens into your script ( blasters ) or update the default.yml
- if you're on OSX ( 10.8/10.9 ) beware the ipv6 lookup issues with vhosts
- [Serverfault thread|http://serverfault.com/questions/321386/resolving-to-virtual-host-very-slow-on-mac-os-x-lion]
- set your VHOSTS from *:80 to 0.0.0.0:80
- Do not use a NAME.local vhost; use .dev or something else as there are some ipv6 implications [ not sure on this one though ]
- [Serverfault thread|http://serverfault.com/questions/321386/resolving-to-virtual-host-very-slow-on-mac-os-x-lion]
- set your VHOSTS from *:80 to 0.0.0.0:80
- Do not use a NAME.local vhost; use .dev or something else as there are some ipv6 implications [ not sure on this one though ]

To use with Chrome/Postman
- copy the tokens as Oauth 1.0
- select add params to header
- select auto add parameters
- add parameters
- Content-Type = application/json
- Accept = application/json

then add to the path/etc and start working it.

Req Payloads:
Until documentation is published there are a few tricks to figuring out what's required.  To do so
- find the api call in webapi.xml and find the service that's being used
- look in the code for the service interface to find out what object it is expecting
- look in the service/data folder and find the DTO that the service interface is expecting
- you need to provide all the data in your request that the DTO expects
- note that the 1st letter of an object should be lower case in your req ( objects can be nested )
- while attributes of an object may be all upper case in the DTO, first letter is always lower case with other letters of words being upper case

API call headers should include:
- Content-Type = application/json
- Accept = application/json

Magento 2 API framework features 

============
```
Result Field Filtering
- Magento can return only the fields a client wants by adding a parameter to the URL call
- Format is:  topLevelObjects[CSVoffields,nestedObjects[field1,field2]],simpleField1
- ex : ?fields=customer[id,email],sampleField,addresses[city,postcode,region[region_code,region]]

Region Data used for API Calls
- Region ID is used by both customer & tax API calls.
- Region data is loaded into directory_country_region table in the database
- ISO country info is loaded into directory_country table in the database

```

Some example payloads for Customer Search (In JSON) - Thanks Anup!

Single customer :  "condition_type": “eq"
============
```
{
    "searchCriteria": {
        "filterGroups": [
            {
                "filters": [
                    {
                        "field": "email",
                        "value": "test@test.com"
                    }
                ]
            },
            {
                "filters": [
                    {
                        "field": "firstname",
                        "value": "anup"
                    },
                    {
                        "field": "lastname",
                        "value": "d"
                    }
                ]
            }
        ],
        "current_page": 1,
        "page_size": 1
    }
}
```
Multiple customers : updated_at example
```
{
	"searchCriteria": {
		"filterGroups": [
		  {
			"filters":[
			  "field":"updated_at",
			  "value":"2014-04-21",
			  "condition_type":"gt"
			]
		  }
		],
		"current_page":1,
		"page_size":10
	}
}
```


Single customer :  "condition_type": "like"
============
```
{
    "searchCriteria": {
        "filterGroups": [
            {
                "filters": [
                    {
                        "field": "email",
                        "value": "%ebay%",
                        "condition_type": "like"
                    }
                ]
            },
            {
                "filters": [
                    {
                        "field": "firstname",
                        "value": "anup"
                    },
                    {
                        "field": "lastname",
                        "value": "d"
                    }
                ]
            }
        ],
        "current_page": 1,
        "page_size": 1
    }
}
```

Multiple Customers :  "condition_type": "like"
===============
```
{
    "searchCriteria": {
        "filterGroups": [
            {
                "filters": [
                    {
                        "field": "email",
                        "value": "%ebay%",
                        "condition_type": "like"
                    },
                    {
                        "field": "email",
                        "value": "%x.com%",
                        "condition_type": "like"
                    }
                ]
            },
            {
                "filters": [
                    {
                        "field": "firstname",
                        "value": "anup"
                    },
                    {
                        "field": "lastname",
                        "value": "d"
                    }
                ]
            }
        ],
        "current_page": 1,
        "page_size": 1
    }
}
```
To create a customer it’s a POST request
url:  http://mage2.demo1/index.php/rest/default/V1/customerAccounts

Create Customer Example Payload
===========================

```
{
    "customerDetails": {
        "customer": {
            "firstname": "FirstName",
            "lastname": "LastName",
            "email": "customer60@magento.com",
            “gender”: “1"
        },
        "addresses": [
            {
                "firstname": "fn1",
                "middlename": "Middle1",
                "lastname": "fn1",
                "company": "X",
                "street": [
                    "7700 W Patrmer ln"
                ],
                "city": "Austin",
                "country_id": "US”, 
                "region": {
                  "region": "Texas",
                  "region_id": 57,
                  "region_code": "TX"
                },
                "postcode": "11111",
                "telephone": "1111111111",
                "vat_id": "1111111",
                "default_billing": false,
                "default_shipping": false               
            },
            {
                "firstname": "fn2",
                "middlename": "Middle2",
                "lastname": "fn2",
                "company": "Y",
                "street": [
                    "7700 W Patrmer ln"
                ],
                "city": "San Jose",
                "country_id": "US”,
                "region": {
                   "region": "Texas",
                   "region_id": 57,
                   "region_code": "TX"
                },
                "postcode": "22222",
                "telephone": "2222222222",
                "vat_id": "2222222",
                "default_billing": true,
                "default_shipping": true          
            }
        ]
    },
    "password": "test@123"
}
```
