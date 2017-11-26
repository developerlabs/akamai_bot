require 'net/http'
require 'uri'
require 'json'
require 'savon'
require 'csv'
require 'slack-ruby-client'

# Akamai config
akamai_user = "my login id"
akamai_password = "my password"
cpcode_list = []

# Slack config
slack_channel = "#general"
bot_user = "Akamai Bot"
slack_webhook_endpoint = "https://hooks.slack.com/services/mywebhookendpoint"

client = Savon.client(
  basic_auth: [akamai_user, akamai_password],
  wsdl: 'https://control.akamai.com/nmrws/services/SiteAcceleratorReportService?wsdl',
  namespaces: {
    'akasiteDeldt' => 'https://control.akamai.com/SiteDeliveryReportService.xsd',
    'akaawsdt'     => 'https://control.akamai.com/Data.xsd',
    'akaaimsdt'    => 'https://control.akamai.com/Data.xsd'
  },
  log: true
)
current_time = DateTime.now()
puts end_date = current_time.iso8601
puts start_date = (current_time - Rational(1, 24)).iso8601
response =  client.call(:get_traffic_summary_for_cp_code, message: {cpcodes: {int: cpcode_list}, startTime: start_date, endTime: end_date})
csv_result = CSV.parse(response.body[:get_traffic_summary_for_cp_code_response][:get_traffic_summary_for_cp_code_return])

# Akamai CSV Header
# Time,Total Pageviews,Total Volume in MB,Edge Traffic Volume in MB,Midgress Traffic Volume in MB,Origin Traffic Volume in MB,Edge Requests,Midgress Requests,Origin Requests,Total Download Volume in MB,Edge Download Response Volume in MB,Midgress Download Response Volume in MB,Origin Download Response Volume in MB,Total Upload Volume in MB,Edge Upload Request and Response Volume in MB,Midgress Upload Request and Response Volume in MB,Origin Upload Request and Response Volume in MB,Edge OK Requests: 200/206/210,Edge 304 Requests,Edge Redirect Requests: 301/302,Edge Permission Requests: 401/403/415,Edge Server Error Requests: 500/501/502/503/504,Edge Client Abort Requests: 000,Edge Other Requests(all other status codes),Edge 403 Requests,Edge 404 Requests,Origin 404 Requests,Origin OK: 200/206/210 Requests,Origin 304 Requests,Origin Redirect: 301/302 Requests,Origin Permission: 401/403/415 Requests,Origin Server Error Requests: 500/501/502/503/504,Origin Other Requests (all other status codes)

text = "Time(UTC), Akamai Volume(MB), Origin Volume(MB), Akamai Request, Origin Request, Origin 50X\n"
csv_result[-8..-1].reverse.each do |row|
  text << [row[0], row[3].to_i, row[5].to_i, row[6], row[8], row[-2]].join(", ")
  text << "\n"
end

payload = {
        "channel": slack_channel,
        "username": bot_user,
        "text": "Reporting Akamai Traffic",
        "attachments": [{
            "color": "#0000FF",
            "title": "Akamai Report",
            "text": text
        }],
        "icon_emoji": ":bus:"
    }.to_json

uri = URI.parse(slack_webhook_endpoint)
https = Net::HTTP.new(uri.host,uri.port)
https.use_ssl = true
request = Net::HTTP::Post.new(uri.path)
request.set_form_data({payload: payload})
res = https.request(request)
