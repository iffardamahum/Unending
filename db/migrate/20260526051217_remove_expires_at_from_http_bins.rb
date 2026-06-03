class RemoveExpiresAtFromHttpBins < ActiveRecord::Migration[8.1]
  def change
    remove_column :http_bins, :expires_at, :datetime
  end
end
