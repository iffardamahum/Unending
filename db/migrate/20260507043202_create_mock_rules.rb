class CreateMockRules < ActiveRecord::Migration[8.1]
  def change
    create_table :mock_rules do |t|
      t.references  :http_bin,       null: false, foreign_key: true
      t.string      :http_method,    null: false
      t.string      :path_pattern,   null: false
      t.string      :name,           null: false
      t.text        :description
      t.integer     :response_status,  null: false, default: 200
      t.jsonb       :response_headers, null: false, default: {}
      t.text        :response_body
      t.string      :content_type,     default: "application/json"
      t.integer     :delay_ms,         default: 0
      t.integer     :priority,         default: 0
      t.boolean     :enabled,          default: true
      t.boolean     :use_regex,        default: false

      t.timestamps
    end

    add_index :mock_rules, [ :http_bin_id, :enabled ]
    add_index :mock_rules, [ :http_bin_id, :http_method, :path_pattern ]
    add_index :mock_rules, :priority
  end
end
