class CleanupJob < ApplicationJob
  def perform
    MockRule.expired.destroy_all
  end
end
