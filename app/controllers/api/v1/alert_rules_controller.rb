class Api::V1::AlertRulesController < Api::V1::BaseController
  before_action :set_alert_rule, only: [ :show, :update, :destroy ]

  def index
    @alert_rules = policy_scope(AlertRule)
                     .includes(:security)
                     .order(created_at: :desc)

    # Apply filters
    @alert_rules = @alert_rules.where(active: params[:active]) if params[:active].present?
    @alert_rules = @alert_rules.where(security_id: params[:security_id]) if params[:security_id].present?
    @alert_rules = @alert_rules.where(condition_type: params[:condition_type]) if params[:condition_type].present?

    render json: {
      data: @alert_rules.as_json(
        include: {
          security: {
            only: [ :id, :symbol, :name ],
            include: {
              latest_quote: {
                only: [ :last_price ]
              }
            }
          }
        }
      )
    }
  end

  def show
    authorize @alert_rule
    render json: {
      data: @alert_rule.as_json(
        include: {
          security: {
            only: [ :id, :symbol, :name ],
            include: {
              latest_quote: {
                only: [ :last_price, :change, :change_percent ]
              }
            }
          },
          alert_events: {
            only: [ :id, :triggered_at, :triggered_value, :resolved_at ],
            limit: 10
          }
        }
      )
    }
  end

  def create
    @alert_rule = current_user.alert_rules.new(alert_rule_params)
    authorize @alert_rule

    if @alert_rule.save
      render json: {
        data: @alert_rule.as_json(
          include: {
            security: {
              only: [ :id, :symbol, :name ]
            }
          }
        ),
        message: "Alert rule created successfully"
      }, status: :created
    else
      render json: {
        errors: @alert_rule.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    authorize @alert_rule

    if @alert_rule.update(alert_rule_params)
      render json: {
        data: @alert_rule.as_json(
          include: {
            security: {
              only: [ :id, :symbol, :name ]
            }
          }
        ),
        message: "Alert rule updated successfully"
      }
    else
      render json: {
        errors: @alert_rule.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @alert_rule

    if @alert_rule.destroy
      render json: {
        message: "Alert rule deleted successfully"
      }
    else
      render json: {
        errors: @alert_rule.errors.full_messages
      }, status: :unprocessable_entity
    end
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
      :message,
      :active
    )
  end
end
