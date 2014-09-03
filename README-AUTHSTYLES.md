# Chuck's notes on different web api authorizations
* (Thanks to Anup & API team for the internal doc's )

# Anonymous Access
* Note only for API's exposed that have 'anonymous' resources 

# Session Based - Frontend
* When a customer logs in; Magento setups a cookie which the webapi framework can read and use for access rights
* Only for webapi's that have 'self' resources

Ie can create AJAX call to 
/rest/V1/customer/me to return customer object for the logged in user

# Session Based - Backend
* When an admin logs in; Magento setups a cookie which the webapi framework can read and sue for access rights
* Will be worked after security work on states/cookies have progressed further

# Customer Token Authorization
* These are long lived tokens; can only be used on 'self' resources; they're long lived but can be revoked
curl -X POST "http://mage2.dev/index.php/rest/V1/integration/customer/token" -H "Content-Type:application/json" -d '{"username":"fred@smith.com", "password":"password"}'

Returns a bearer token
"0pgs4c0eyufyjhe5k7ysr5m7g7yfl4bo"

I can then use this token for any resources marked 'self'  

Ie
curl -X GET "http://mage2.dev/index.php/rest/V1/customer/me" -H "Authorization: Bearer 0pgs4c0eyufyjhe5k7ysr5m7g7yfl4bo"

Which returns my customer object

{"id":"2","website_id":"1","created_in":"Default Store View","store_id":"1","group_id":"1","custom_attributes":[{"attribute_code":"disable_auto_group_change","value":"0"}],"firstname":"Fred","lastname":"Smith","email":"fred@smith.com","default_billing":"2","default_shipping":"2","created_at":"2014-09-03 21:19:38"}

# Admin Token Authorization
* Note only for API's exposed that have valid resource nodes

* Get a token (with your admin credentials)
curl -X POST "http://mage2.dev/index.php/rest/V1/integration/admin/token" -H "Content-Type:application/json" -d '{"username":"magento","password":"bobsyouruncle"}'

Returns a bearer token
"icelbik5s0257st9ksu62ohuk9f5qudd"

* Call a admin API with your bearer token
curl -X GET "http://mage2.dev/index.php/rest/V1/customerAccounts/1" -H "Authorization: Bearer icelbik5s0257st9ksu62ohuk9f5qudd"

Returns the customer object

{"customer":{"id":"1","website_id":"1","created_in":"Default Store View","store_id":"1","group_id":"1","custom_attributes":[{"attribute_code":"disable_auto_group_change","value":"0"}],"firstname":"Bob","lastname":"Smith","email":"bob@smith.com","default_billing":"1","default_shipping":"1","created_at":"2014-09-03 21:05:28","gender":"1"},"addresses":[{"firstname":"Bob","lastname":"Smith","street":["1 Main Street"],"city":"Austin","country_id":"US","region":{"region":"Texas","region_id":57,"region_code":"TX"},"postcode":"77777","telephone":"5555555555","default_billing":true,"default_shipping":true,"id":"1","customer_id":"1"}]}

* Or get products
curl -X GET "http://mage2.dev/index.php/rest/V1/products/1" -H "Authorization: Bearer icelbik5s0257st9ksu62ohuk9f5qudd"

which reminds me I should have created a product
{"message":"There is no product with provided SKU"}

