class AddRateLimitTypeToMockRules < ActiveRecord::Migration[8.1]
  def change
    add_column :mock_rules, :rate_limit_type, :string
  end
end
