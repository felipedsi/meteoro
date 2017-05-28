Sequel.migration do
  change do
    create_table(:deploys) do
      primary_key :id
      foreign_key :user_id, :users, null: false
      Integer :status, null: false
      index [:user_id, :status]
    end
  end
end
