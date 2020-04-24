class User < ApplicationRecord
  before_create :set_external_id
  after_create :create_in_salesforce
  after_update :update_in_salesforce

  private

  def set_external_id
    self.external_id = SecureRandom.hex(6)
  end

  def create_in_salesforce
    SfCreateService.call(self)
  end

  def update_in_salesforce
    return if skip_salesforce_update

    sf_client.upsert!('Contact', Id: self.salesforce_id, lastname: self.last_name, firstname: self.first_name, email: self.email, ExternalId__c: self.external_id)
  end
end
