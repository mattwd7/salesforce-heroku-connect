class User < ApplicationRecord
  before_create :set_external_id
  after_create :create_in_salesforce
  before_update :initialize_sf_updater
  after_update :update_in_salesforce

  private

  def set_external_id
    self.external_id = SecureRandom.hex(6)
  end

  def create_in_salesforce
    SfCreateService.call(self)
  end

  def initialize_sf_updater
    return if skip_salesforce_update

    @sf_updater = SfUpdaterService.new(self, changed)
  end

  def update_in_salesforce
    return if skip_salesforce_update

    @sf_updater.call
  end
end
