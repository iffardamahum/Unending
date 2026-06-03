ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :role

  controller do
    def update
      if resource.super_admin? && !current_admin_user.super_admin?
        redirect_to admin_users_path, alert: "Cannot edit super admin."
        return
      end

      if resource == current_admin_user && resource.super_admin? && params[:user][:role] != "super_admin"
        redirect_to admin_users_path, alert: "Super admin cannot change their own role."
        return
      end

      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      super
    end

    def destroy
      if resource.super_admin?
        redirect_to admin_users_path, alert: "Cannot delete super admin."
        return
      end
      super
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :role do |user|
      status_tag user.role,
        class: case user.role
               when "super_admin" then "orange"
               when "admin" then "green"
               else "gray"
               end
    end
    column :sign_in_count
    column :last_sign_in_at
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :role
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
      f.input :role, as: :select,
              collection: current_admin_user.super_admin? ? User::ROLES : %w[member admin],
              include_blank: false
      f.input :password, required: false
      f.input :password_confirmation, required: false
    end
    f.actions
  end

  filter :email
  filter :role, as: :select, collection: User::ROLES
  filter :created_at
end
