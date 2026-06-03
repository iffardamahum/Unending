class AddRateLimitToMockRules < ActiveRecord::Migration[8.1]
  def change
    add_column :mock_rules, :rate_limit_count, :integer
    add_column :mock_rules, :rate_limit_period, :string # nil, 'minute', 'hour', 'day'
  end
end
