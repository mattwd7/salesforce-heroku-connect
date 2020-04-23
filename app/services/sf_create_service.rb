class SfCreateService
  def self.call(*args)
    new(*args).call
  end

  def initialize(resource)
    @resource = resource
  end

  def call
    sobject_id = sf_client.create!(resource.class.to_s, mapped_attributes)
    # binding.pry
    resource.skip_salesforce_update = true
    resource.update(salesforce_id: sobject_id)
  end

  private

  attr_reader :resource

  def sf_client
    @sf_client ||= Restforce.new
  end

  def resource_mappings
    @resource_mappings ||= File.open(Rails.root.join('salesforce_mappings.yml')) do |f|
      YAML.safe_load(f)[resource.class.to_s]
    end
  end

  def mapped_attributes
    resource_mappings['field_mappings'].invert.each_with_object({}) do |(sf_name, attr_name), obj|
      obj[sf_name.to_sym] = resource[attr_name]
      obj
    end
  end
end
