require 'restforce'
require 'faye'

# Initialize a client with your username/password.
client = Restforce.new

begin
  client.authenticate!
  puts 'Successfully authenticated to salesforce.com'

  Thread.new do
    EM.run do
      client.subscription '/topic/AllPosts', replay: -1 do |message|
        puts 'New Message!', message.inspect, message.class
        sobject = message['sobject']

        post = Post.find_by(salesforce_id: sobject['Id'])
        post.skip_salesforce = true
        post.update(title: sobject['Name'])
      end
    end
  end
rescue
  puts "Could not authenticate. Not listening for streaming events."
end
