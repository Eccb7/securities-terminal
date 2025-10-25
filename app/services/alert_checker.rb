# Service to check alert rules and trigger notifications
class AlertChecker
  def self.check_all_active_alerts
    AlertRule.active.includes(:security, :user).find_each do |alert_rule|
      check_alert(alert_rule)
    end
  end

  def self.check_alerts_for_security(security)
    AlertRule.active
             .where(security: security)
             .includes(:user)
             .find_each do |alert_rule|
      check_alert(alert_rule)
    end
  end

  def self.check_alert(alert_rule)
    return unless alert_rule.active?

    latest_quote = alert_rule.security.latest_quote
    return unless latest_quote

    actual_value = get_actual_value(alert_rule, latest_quote)
    return unless actual_value

    if condition_met?(alert_rule, actual_value)
      trigger_alert(alert_rule, actual_value)
    end
  end

  private

  def self.get_actual_value(alert_rule, quote)
    case alert_rule.condition_type
    when "price"
      quote.last_price
    when "volume"
      quote.volume
    when "percent_change"
      quote.price_change_percentage
    else
      nil
    end
  end

  def self.condition_met?(alert_rule, actual_value)
    threshold = alert_rule.threshold_value

    case alert_rule.comparison_operator
    when "greater_than"
      actual_value > threshold
    when "less_than"
      actual_value < threshold
    when "equals"
      (actual_value - threshold).abs < 0.01 # Allow small floating point difference
    else
      false
    end
  end

  def self.trigger_alert(alert_rule, actual_value)
    # Check if alert was recently triggered (within last 15 minutes) to avoid spam
    recent_trigger = alert_rule.alert_events
                               .where("triggered_at > ?", 15.minutes.ago)
                               .exists?
    return if recent_trigger

    # Create alert event
    alert_event = alert_rule.alert_events.create!(
      triggered_at: Time.current,
      actual_value: actual_value,
      status: "pending",
      message: build_alert_message(alert_rule, actual_value)
    )

    # Update alert rule status to triggered
    alert_rule.update(status: "triggered")

    # Send notifications
    send_notifications(alert_rule, alert_event)

    # Broadcast to user's channel
    broadcast_alert(alert_rule, alert_event)
  end

  def self.build_alert_message(alert_rule, actual_value)
    security = alert_rule.security
    condition = alert_rule.condition_type
    operator = alert_rule.comparison_operator.gsub("_", " ")
    threshold = alert_rule.threshold_value

    case condition
    when "price"
      "#{security.ticker} price (#{format_currency(actual_value)}) #{operator} #{format_currency(threshold)}"
    when "volume"
      "#{security.ticker} volume (#{format_number(actual_value)}) #{operator} #{format_number(threshold)}"
    when "percent_change"
      "#{security.ticker} change (#{format_percent(actual_value)}) #{operator} #{format_percent(threshold)}"
    end
  end

  def self.send_notifications(alert_rule, alert_event)
    case alert_rule.notification_method
    when "email"
      send_email_notification(alert_rule, alert_event)
    when "in_app"
      # Already handled by broadcast
      true
    when "both"
      send_email_notification(alert_rule, alert_event)
    end
  end

  def self.send_email_notification(alert_rule, alert_event)
    # TODO: Implement email notification using ActionMailer
    # AlertMailer.price_alert(alert_rule.user, alert_event).deliver_later
    Rails.logger.info "Email notification would be sent to #{alert_rule.user.email} for alert event ##{alert_event.id}"
  end

  def self.broadcast_alert(alert_rule, alert_event)
    # Broadcast to user's personal notification channel
    ActionCable.server.broadcast(
      "notifications_#{alert_rule.user_id}",
      {
        type: "alert_triggered",
        alert_rule_id: alert_rule.id,
        alert_event_id: alert_event.id,
        security_ticker: alert_rule.security.ticker,
        message: alert_event.message,
        triggered_at: alert_event.triggered_at.iso8601
      }
    )
  end

  # Formatting helpers
  def self.format_currency(value)
    "KES #{sprintf('%.2f', value)}"
  end

  def self.format_number(value)
    value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  end

  def self.format_percent(value)
    "#{sprintf('%.2f', value)}%"
  end
end
