require 'restforce'
require 'faye'

# Initialize a client with your username/password.
client = Restforce.new

f = File.open(Rails.root.join('salesforce_mappings.yml'))
sf_mappings = HashWithIndifferentAccess.new(YAML.load(f))

# begin
#   client.authenticate!
#   puts 'Successfully authenticated to salesforce.com'

#   Thread.new do
#     EM.run do
#       sf_mappings.each do |table_to_sync, properties|
#         next unless properties['sf_channel_name']

#         client.subscription "/topic/#{properties['sf_channel_name']}", replay: -1 do |message|
#           puts 'New Message!', message.inspect, message.class
#           sobject = message['sobject']

#           resource = table_to_sync.constantize.find_by(salesforce_id: sobject['Id'])
#           resource.skip_salesforce_update = true
#           resource.update(**properties['field_mappings'].symbolize_keys)
#         end
#       end
#     end
#   end
# rescue
#   puts "Could not authenticate. Not listening for streaming events."
# end
