class Post < ApplicationRecord
  belongs_to :user

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

    sf_client.upsert!('Post__c', Id: self.salesforce_id, Name: self.title, content__c: self.content, Contact__c: self.user.salesforce_id)
  end
end
