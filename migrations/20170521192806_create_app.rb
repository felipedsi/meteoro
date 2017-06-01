Sequel.migration do
  change do
    create_table(:apps) do
      primary_key :id
      foreign_key :user_id, :users, null: false
      Integer :status, null: false
      String :host, null: false
      index [:user_id, :status]
    end
  end
end
