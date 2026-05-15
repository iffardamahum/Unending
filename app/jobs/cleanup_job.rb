class CleanupJob < ApplicationJob
  def perform
    HttpBin.expired.destroy_all
  end
end
