class User < ApplicationRecord
  before_create :set_external_id, :create_in_salesforce
  after_update :send_to_salesforce

  private

  def set_external_id
    self.external_id = SecureRandom.hex(6)
  end

  def create_in_salesforce
    self.salesforce_id = sf_client.create!('Contact', lastname: self.last_name, firstname: self.first_name, email: self.email, ExternalId__c: self.external_id)
  end

  def send_to_salesforce
    sf_client.upsert!('Contact', Id: self.salesforce_id, lastname: self.last_name, firstname: self.first_name, email: self.email, ExternalId__c: self.external_id)
  end
end
