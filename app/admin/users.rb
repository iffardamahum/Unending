ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :sign_in_count
    column :last_sign_in_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :sign_in_count
      row :last_sign_in_at
      row :created_at
    end
    panel "HTTP Bins" do
      table_for resource.http_bins do
        column :name
        column :token
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  filter :email
  filter :created_at
end
