class SfStreamingService
  def self.start
    new.start
  end

  def start
    begin
      sf_client.authenticate!
      puts 'Successfully authenticated to salesforce.com'

      Thread.new do
        EM.run { establish_subscriptions }
      end
    rescue
      puts "Could not authenticate. Not listening for streaming events."
    end
  end

  private

  def sf_client
    @sf_client ||= Restforce.new
  end

  def sf_mappings
    return @sf_mappings if defined? @sf_mappings

    mappings_path = Rails.root.join('salesforce_mappings.yml')
    @sf_mappings = File.open(mappings_path) do |f|
      YAML.safe_load(f)
    end
  end

  def establish_subscriptions
    live_push_topic_names = sf_client.query('select Name from PushTopic').pluck(:Name)
    puts '!!', live_push_topic_names

    sf_mappings.each do |model_name, sf_properties|
      channel_name = sf_properties['sf_channel_name']
      next unless channel_name

      if (live_push_topic_names.include?(channel_name))
        sf_client.subscription "/topic/#{channel_name}", replay: -1 do |message|
          sobject = message['sobject']

          resource = model_name.constantize.find_by(salesforce_id: sobject['Id'])
          resource.skip_salesforce_update = true
          resource.update(**sobject_to_attributes(sobject, sf_properties['field_mappings']))
        end
      else
        warning_message = "#{channel_name} topic does not exist in Salesforce!"
        puts warning_message
        Rails.logger.warn(warning_message)
      end
    end
  end

  def sobject_to_attributes(sobject, field_mappings)
    sobject.each_with_object({}) do |(sf_name, sf_value), obj|
      attr_name = field_mappings.invert[sf_name]

      obj[attr_name.to_sym] = sf_value if attr_name
      obj
    end
  end
end
