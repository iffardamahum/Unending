class DashboardController < ApplicationController
  def index
    @bins = current_user.http_bins.order(created_at: :desc)
    @recent_requests = CapturedRequest
                         .joins(:http_bin)
                         .where(http_bins: { user_id: current_user.id })
                         .recent.limit(20)

    @stats = {
      total_bins:     @bins.count,
      total_requests: @recent_requests.count,
      matched:        @recent_requests.matched.count,
      total_rules:    current_user.mock_rules.count
    }
  end
end
