class AddMatchedRuleIdToCapturedRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :captured_requests, :matched_rule_id, :integer
  end
end
