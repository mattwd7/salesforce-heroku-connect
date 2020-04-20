class AddSalesforceIdToModels < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :salesforce_id, :string
    add_column :posts, :salesforce_id, :string
  end
end
