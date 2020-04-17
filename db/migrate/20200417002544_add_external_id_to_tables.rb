class AddExternalIdToTables < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :external_id, :string
    User.all.each do |user|
      user.send(:set_external_id)
      user.save
    end
    change_column_null :users, :external_id, false

    add_column :posts, :external_id, :string
    Post.all.each do |post|
      post.send(:set_external_id)
      post.save
    end
    change_column_null :posts, :external_id, false
  end
end
