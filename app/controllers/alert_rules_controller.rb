class AlertRulesController < ApplicationController
  before_action :set_alert_rule, only: [ :show, :edit, :update, :destroy ]

  def index
    @alert_rules = policy_scope(AlertRule)
                     .includes(:security, :user)
                     .where(user: current_user)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(25)

    # Filter by status
    @alert_rules = @alert_rules.where(status: params[:status]) if params[:status].present?
  end

  def show
    authorize @alert_rule
    @alert_events = @alert_rule.alert_events.order(triggered_at: :desc).limit(20)
  end

  def new
    @alert_rule = current_user.alert_rules.build
    authorize @alert_rule
    @securities = Security.active.order(:ticker)
  end

  def create
    @alert_rule = current_user.alert_rules.build(alert_rule_params)
    authorize @alert_rule

    if @alert_rule.save
      redirect_to @alert_rule, notice: "Alert rule created successfully"
    else
      @securities = Security.active.order(:ticker)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @alert_rule
    @securities = Security.active.order(:ticker)
  end

  def update
    authorize @alert_rule

    if @alert_rule.update(alert_rule_params)
      redirect_to @alert_rule, notice: "Alert rule updated successfully"
    else
      @securities = Security.active.order(:ticker)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @alert_rule
    @alert_rule.destroy
    redirect_to alert_rules_path, notice: "Alert rule deleted successfully"
  end

  private

  def set_alert_rule
    @alert_rule = AlertRule.find(params[:id])
  end

  def alert_rule_params
    params.require(:alert_rule).permit(
      :security_id,
      :condition_type,
      :threshold_value,
      :comparison_operator,
      :notification_method,
      :status
    )
  end
end
