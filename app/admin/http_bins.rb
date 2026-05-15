ActiveAdmin.register HttpBin do
  menu label: "HTTP Bins"

  permit_params :name, :description, :user_id

  index do
    selectable_column
    id_column
    column :name
    column :token
    column :user
    column :captured_requests_count do |bin|
      bin.captured_requests.count
    end
    column :created_at
    column :expires_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :token
      row :description
      row :user
      row :ingest_url
      row :created_at
      row :expires_at
    end

    panel "Captured Requests (last 10)" do
      table_for resource.captured_requests.recent.limit(10) do
        column :request_id
        column :http_method
        column :path
        column :response_status
        column :matched_mock
        column :created_at
        column :expires_at
      end
    end

    panel "Mock Rules" do
      table_for resource.mock_rules.ordered do
        column :name
        column :http_method
        column :path_pattern
        column :response_status
        column :enabled
        column :priority
        column :created_at
        column :expires_at
      end
    end
  end

  filter :user
  filter :name
  filter :token
  filter :created_at
end
