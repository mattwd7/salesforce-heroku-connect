class User < ApplicationRecord
  before_create :set_external_id
  after_create :send_to_salesforce
  after_update :send_to_salesforce

  private

  def set_external_id
    self.external_id = SecureRandom.hex(6)
  end

  def send_to_salesforce
    sf_client.upsert('Contact', 'ExternalId__c', ExternalId__c: self.external_id, lastname: self.last_name, firstname: self.first_name, email: self.email)
  end
end
