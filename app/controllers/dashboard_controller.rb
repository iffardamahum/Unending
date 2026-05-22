class DashboardController < ApplicationController
  def index
    @bins = current_user.http_bins.order(created_at: :desc, expires_at: :asc)
    @recent_requests = CapturedRequest
                         .joins(:http_bin)
                         .where(http_bins: { user_id: current_user.id })
                         .recent.limit(20)

    today = CapturedRequest.joins(:http_bin)
            .where(http_bins: { user_id: current_user.id })
            .where("captured_requests.created_at >= ?", Time.current.beginning_of_day)
            .count

    yesterday = CapturedRequest.joins(:http_bin)
                .where(http_bins: { user_id: current_user.id })
                .where(captured_requests: { created_at: 1.day.ago.    beginning_of_day..1.day.ago.end_of_day })
                .count

    @stats = {
      total_bins:     @bins.count,
      total_requests: @recent_requests.count,
      matched:        @recent_requests.matched.count,
      total_rules:    current_user.mock_rules.count,
      today:          today,
      yesterday:      yesterday
    }
  end
end
