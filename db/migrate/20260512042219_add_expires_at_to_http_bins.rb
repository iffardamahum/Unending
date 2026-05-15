class AddExpiresAtToHttpBins < ActiveRecord::Migration[8.1]
  def change
    add_column :http_bins, :expires_at, :datetime, 
                null: false,
                default: -> { "now() + INTERVAL '30 days'" }
  end
end
