class AddMockRuleIdToCapturedRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :captured_requests, :mock_rule_id, :integer
    add_index :captured_requests, :mock_rule_id
  end
end
