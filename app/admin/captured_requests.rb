ActiveAdmin.register CapturedRequest do
  menu label: "Captured Requests"

  actions :index, :show, :destroy

  index do
    selectable_column
    id_column
    column :http_bin
    column :http_method
    column :path
    column :response_status
    column :matched_mock
    column :remote_ip
    column :duration_ms
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :request_id
      row :http_bin
      row :http_method
      row :path
      row :content_type
      row :remote_ip
      row :response_status
      row :matched_mock
      row :duration_ms
      row :created_at
      row :headers do |r|
        pre JSON.pretty_generate(r.headers)
      end
      row :query_params do |r|
        pre JSON.pretty_generate(r.query_params)
      end
      row :body
      row :response_body
    end
  end

  filter :http_bin
  filter :http_method, as: :select, collection: CapturedRequest::HTTP_METHODS
  filter :response_status
  filter :matched_mock
  filter :created_at
end
