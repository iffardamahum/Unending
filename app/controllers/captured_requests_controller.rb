class CapturedRequestsController < ApplicationController
  before_action :set_bin
  before_action :set_request, only: %i[show destroy]

  def show; end

  def destroy
    @request.destroy
    redirect_to @bin, notice: "Request deleted."
  end

  private

  def set_bin
    @bin = current_user.http_bins.find(params[:http_bin_id])
  end

  def set_request
    @captured_request = @bin.captured_requests.find(params[:id])
  end
end
