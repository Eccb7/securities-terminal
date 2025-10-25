class AlertCheckerJob < ApplicationJob
  queue_as :default

  def perform(security_id = nil)
    if security_id
      security = Security.find(security_id)
      AlertChecker.check_alerts_for_security(security)
    else
      AlertChecker.check_all_active_alerts
    end
  end
end
