ActiveAdmin.register MockRule do
  menu label: "Mock Rules"

  permit_params :name, :description, :http_method, :path_pattern,
                :response_status, :response_body, :content_type,
                :delay_ms, :priority, :enabled, :use_regex,
                :http_bin_id

  index do
    selectable_column
    id_column
    column :name
    column :http_bin
    column :http_method
    column :path_pattern
    column :response_status
    column :enabled
    column :priority
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :http_bin
      row :http_method
      row :path_pattern
      row :use_regex
      row :response_status
      row :content_type
      row :delay_ms
      row :priority
      row :enabled
      row :description
      row :response_headers do |r|
        pre JSON.pretty_generate(r.response_headers)
      end
      row :response_body
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Rule Details" do
      f.input :http_bin
      f.input :name
      f.input :description
      f.input :http_method, as: :select, collection: MockRule::HTTP_METHODS
      f.input :path_pattern, hint: "e.g. /api/users/* or a regex"
      f.input :use_regex
    end
    f.inputs "Response" do
      f.input :response_status
      f.input :content_type
      f.input :delay_ms
      f.input :response_body, as: :text, input_html: { rows: 8 }
    end
    f.inputs "Options" do
      f.input :priority
      f.input :enabled
    end
    f.actions
  end

  filter :http_bin
  filter :http_method, as: :select, collection: MockRule::HTTP_METHODS
  filter :enabled
  filter :created_at
end
