class Post < ApplicationRecord
  belongs_to :user

  private

  def set_external_id
    self.external_id = SecureRandom.hex(6)
  end
end
