class Post < ApplicationRecord
  belongs_to :user

  before_create :set_external_id, :create_in_salesforce
  after_update :send_to_salesforce

  attr_accessor :skip_salesforce

  private

  def set_external_id
    self.external_id = SecureRandom.hex(6)
  end

  def create_in_salesforce
    self.salesforce_id = sf_client.create!('Post__c', external_id__c: self.external_id, Name: self.title, content__c: self.content, Contact__c: self.user.salesforce_id)
  end

  def send_to_salesforce
    return if skip_salesforce

    sf_client.upsert!('Post__c', Id: self.salesforce_id, Name: self.title, content__c: self.content, Contact__c: self.user.salesforce_id)
  end
end
