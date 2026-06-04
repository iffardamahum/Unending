ActiveAdmin.register HttpBin do
  menu label: "HTTP Bins"

  permit_params :name, :description, :user_id, :expires_at

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
    actions
  end
  # Edit form
  form do |f|
   f.inputs do
     f.input :name
     f.input :description
     f.input :user_id
   end
   f.actions
  end

  show do
    attributes_table do
     row :id
     row :name
     row :token
     row :user_id
     row :request_count
     row :created_at
      row :updated_at
  end

    panel "Captured Requests (last 10)" do
      table_for resource.captured_requests.recent.limit(10) do
        column :request_id
        column :http_method
        column :path
        column :response_status
        column :matched_mock
        column :created_at
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
