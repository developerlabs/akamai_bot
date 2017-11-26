# Akamai Bot

Slack bot which posts Akamai traffic made by ruby  
Traffic will be fetched by Akamai SOAP endpoint

## Requires

Ruby 2.2 (above not confirmed)

## Install

```
bundle install --path=vendor/bundle
```

modify below parameters in akamai_traffic.rb
```
akamai_user = "my login id"
akamai_password = "my password"
cpcode_list = []
```

modify slack config
```
slack_channel = "#general"
bot_user = "Akamai Bot"
slack_webhook_endpoint = "https://hooks.slack.com/services/mywebhookendpoint"
```


## Run

```
bundle exec ruby akamai_traffic.rb
```


