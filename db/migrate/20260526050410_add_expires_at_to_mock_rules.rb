class AddExpiresAtToMockRules < ActiveRecord::Migration[8.1]
  def change
    add_column :mock_rules, :expires_at, :datetime
  end
end
