class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  attr_accessor :skip_salesforce_update

  def sf_client
    @sf_client ||= Restforce.new
  end

  def sf_mappings
    f = File.open(Rails.root.join('salesforce_mappings.yml'))
    YAML.safe_load(f)[self.class.to_s]
  end
end
