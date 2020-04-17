class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def sf_client
    @sf_client ||= Restforce.new
  end
end
