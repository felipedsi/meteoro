Sequel.migration do
  change do
  	add_column :users, :access_token, String, null: false
  end
end
