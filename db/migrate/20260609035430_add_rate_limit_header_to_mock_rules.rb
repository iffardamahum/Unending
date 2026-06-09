class AddRateLimitHeaderToMockRules < ActiveRecord::Migration[8.1]
  def change
    add_column :mock_rules, :rate_lmit_header, :string
  end
end
