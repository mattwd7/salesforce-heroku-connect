Restforce.configure do |config|
  config.instance_url = 'https://brave-otter-niswdk-dev-ed.lightning.force.com'
  config.username = ENV['SALESFORCE_USERNAME']
  config.password = ENV['SALESFORCE_PASSWORD']
  config.client_id = ENV['SALESFORCE_CLIENT_ID']
  config.client_secret = ENV['SALESFORCE_CLIENT_SECRET']
  config.security_token = ENV['SALESFORCE_SECURITY_TOKEN']
  config.api_version = '48.0'
end

# client = Restforce.new

# client.create!(
#   'PushTopic',
#   ApiVersion: '23.0',
#   Name: 'AllPosts',
#   Description: 'All account records',
#   NotifyForOperations: 'All',
#   NotifyForFields: 'All',
#   Query: "select Id, Name from Post__c"
# )

# EM.run do
#   client.subscription '/topic/AllPosts' do |message|
#     puts 'We have a message!', message.inspect
#     Rails.logger.info 'We have a message!', message.inspect
#   end
# end
