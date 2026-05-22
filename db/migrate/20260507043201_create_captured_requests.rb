class CreateCapturedRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :captured_requests do |t|
      t.references  :http_bin,     null: false, foreign_key: true
      t.string      :request_id,   null: false
      t.string      :http_method,  null: false
      t.string      :path,         null: false
      t.jsonb       :headers,      null: false, default: {}
      t.jsonb       :query_params, null: false, default: {}
      t.text        :body
      t.string      :content_type
      t.string      :remote_ip
      t.integer     :response_status,  default: 200
      t.jsonb       :response_headers, null: false, default: {}
      t.text        :response_body
      t.float       :duration_ms
      t.boolean     :matched_mock,     default: false

      t.timestamps
    end

    add_index :captured_requests, :request_id, unique: true
    add_index :captured_requests, [ :http_bin_id, :created_at ]
    add_index :captured_requests, [ :http_bin_id, :http_method ]
    add_index :captured_requests, :matched_mock
  end
end
