class HttpBinsController < ApplicationController
  before_action :set_bin, only: %i[show edit update destroy]

  def index
    @bins = current_user.http_bins.order(created_at: :desc)
  end

  def show
    @http_bin = HttpBin.find(params[:id])
    @pagy, @requests = pagy(
      @http_bin.captured_requests.order(created_at: :desc),
      items: 25
    )
    @rules = @bin.mock_rules.ordered
    @stats = CapturedRequest.stats_for(@bin)
  end

  def new
    @bin = current_user.http_bins.build
  end

  def create
    @bin = current_user.http_bins.build(bin_params)
    if @bin.save
      redirect_to @bin, notice: "Bin created! Start sending requests to #{@bin.ingest_url}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @bin.update(bin_params)
      redirect_to @bin, notice: "Bin updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bin.destroy
    redirect_to http_bins_path, notice: "Bin deleted."
  end

  private

  def set_bin
    @bin = current_user.http_bins.find(params[:id])
  end

  def bin_params
    params.require(:http_bin).permit(:name, :description)
  end
end
