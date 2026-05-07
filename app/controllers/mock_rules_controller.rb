class MockRulesController < ApplicationController
  before_action :set_bin
  before_action :set_rule, only: %i[edit update destroy]

  def new
    @rule = @bin.mock_rules.build(response_status: 200, http_method: "ANY")
  end

  def create
    @rule = @bin.mock_rules.build(rule_params)
    if @rule.save
      redirect_to @bin, notice: "Mock rule created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @rule.update(rule_params)
      redirect_to @bin, notice: "Mock rule updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rule.destroy
    redirect_to @bin, notice: "Mock rule deleted."
  end

  private

  def set_bin
    @bin = current_user.http_bins.find(params[:http_bin_id])
  end

  def set_rule
    @rule = @bin.mock_rules.find(params[:id])
  end

  def rule_params
    params.require(:mock_rule).permit(
      :name, :description, :http_method, :path_pattern,
      :response_status, :response_body, :content_type,
      :delay_ms, :priority, :enabled, :use_regex,
      response_headers: {}
    )
  end
end
