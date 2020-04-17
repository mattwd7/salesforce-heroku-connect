class User < ApplicationRecord
  # self.salesforce_table = 'Contact'

  before_create :set_external_id
  after_create :create_in_salesforce
  # after_update :update_in_salesforce

  private

  def set_external_id
    self.external_id = SecureRandom.hex(6)
  end

  def create_in_salesforce
    sf_client.create('Contact', lastname: self.last_name, firstname: self.first_name, email: self.email)
  end

  def sf_client
    @sf_client ||= Restforce.new
  end
end
