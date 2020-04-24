class SfUpdaterService
  def initialize(resource, updated_attrs)
    @resource = resource
    @updated_attrs = updated_attrs
  end

  def call
    sf_client.upsert!(
      resource_mappings['sf_table_name'],
      'Id',
      Id: resource.salesforce_id,
      **mapped_attributes
    )
  end

  private

  attr_reader :resource, :updated_attrs

  def sf_client
    @sf_client ||= Restforce.new
  end

  def resource_mappings
    @resource_mappings ||= File.open(Rails.root.join('salesforce_mappings.yml')) do |f|
      YAML.safe_load(f)[resource.class.to_s]
    end
  end

  def mapped_attributes
    resource_mappings['field_mappings']
      .slice(*updated_attrs)
      .invert
      .each_with_object({}) do |(sf_name, attr_name), obj|
        obj[sf_name.to_sym] = resource[attr_name]
        obj
      end
  end
end
