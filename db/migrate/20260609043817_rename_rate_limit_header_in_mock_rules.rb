class RenameRateLimitHeaderInMockRules < ActiveRecord::Migration[7.0]
  def change
    rename_column :mock_rules, :rate_lmit_header, :rate_limit_header
  end
end
