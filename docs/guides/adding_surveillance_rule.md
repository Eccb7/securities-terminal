# Adding a Surveillance Rule

This guide explains how to add custom compliance and surveillance rules to detect suspicious trading patterns.

## Overview

The surveillance system monitors trading activity in real-time and triggers alerts when suspicious patterns are detected. Rules are configurable and can be customized per organization.

## Rule Types

Built-in rule types include:
- `large_order`: Detect unusually large orders
- `rapid_trading`: Detect high-frequency trading patterns
- `wash_trading`: Detect potential wash trading
- `front_running`: Detect potential front-running patterns
- `insider_trading_pattern`: Detect suspicious timing around news
- `price_manipulation`: Detect potential price manipulation

## Step 1: Define Rule Configuration

Add your rule type to the AlertRule model:

```ruby
# app/models/alert_rule.rb
class AlertRule < ApplicationRecord
  RULE_TYPES = {
    'large_order' => 'Large Order Detection',
    'rapid_trading' => 'Rapid Trading Pattern',
    'your_custom_rule' => 'Your Custom Rule Description'
  }.freeze

  validates :rule_type, inclusion: { in: RULE_TYPES.keys }
end
```

## Step 2: Create Rule Processor

Create a new processor class in `app/services/surveillance/`:

```ruby
# app/services/surveillance/your_custom_rule_processor.rb
module Surveillance
  class YourCustomRuleProcessor < BaseProcessor
    # Process a single event (order, trade, quote, etc.)
    # @param event [Hash] The event to process
    # @param rule [AlertRule] The rule configuration
    # @return [Boolean] true if alert should be triggered
    def process(event, rule)
      # Extract parameters from rule configuration
      threshold = rule.expression['threshold']
      timeframe = rule.expression['timeframe_minutes']
      
      # Your detection logic here
      if violates_rule?(event, threshold, timeframe)
        create_alert(event, rule)
        return true
      end
      
      false
    end

    private

    def violates_rule?(event, threshold, timeframe)
      # Implement your detection logic
      # Example: Check if event meets certain criteria
      
      case event[:type]
      when 'order'
        check_order_pattern(event, threshold, timeframe)
      when 'trade'
        check_trade_pattern(event, threshold, timeframe)
      else
        false
      end
    end

    def check_order_pattern(event, threshold, timeframe)
      # Example: Check recent orders from same user
      user_id = event[:user_id]
      security_id = event[:security_id]
      
      recent_orders = Order.where(
        user_id: user_id,
        security_id: security_id,
        created_at: timeframe.minutes.ago..Time.current
      )
      
      # Your specific logic
      recent_orders.count > threshold
    end

    def check_trade_pattern(event, threshold, timeframe)
      # Implement trade pattern checking
      false
    end

    def create_alert(event, rule)
      AlertEvent.create!(
        alert_rule: rule,
        severity: rule.severity,
        payload: {
          event_type: event[:type],
          event_id: event[:id],
          detected_at: Time.current,
          details: build_alert_details(event, rule)
        },
        message: build_alert_message(event, rule)
      )
    end

    def build_alert_details(event, rule)
      {
        rule_name: rule.name,
        user_id: event[:user_id],
        security_id: event[:security_id],
        threshold: rule.expression['threshold'],
        actual_value: calculate_actual_value(event)
      }
    end

    def build_alert_message(event, rule)
      "#{rule.name} triggered for user #{event[:user_id]} " \
      "on security #{event[:security_id]}"
    end

    def calculate_actual_value(event)
      # Calculate the actual value that triggered the alert
      event[:quantity] || event[:volume] || 0
    end
  end
end
```

## Step 3: Register the Processor

Register your processor in the surveillance engine:

```ruby
# config/initializers/surveillance.rb
Rails.application.config.after_initialize do
  Surveillance::Engine.register_processor(
    :your_custom_rule,
    Surveillance::YourCustomRuleProcessor
  )
end
```

## Step 4: Create Migration for Rule Configuration

If your rule needs additional database fields:

```ruby
rails generate migration AddCustomFieldsToAlertRules

# db/migrate/XXXXXX_add_custom_fields_to_alert_rules.rb
class AddCustomFieldsToAlertRules < ActiveRecord::Migration[8.0]
  def change
    # Add any custom fields needed for your rule
    add_column :alert_rules, :custom_config, :jsonb, default: {}
    add_index :alert_rules, :custom_config, using: :gin
  end
end
```

## Step 5: Add Admin UI Configuration

Add form fields for rule configuration in the admin interface:

```erb
<!-- app/views/admin/alert_rules/_form.html.erb -->
<%= form_with(model: [:admin, alert_rule]) do |f| %>
  
  <% if alert_rule.rule_type == 'your_custom_rule' %>
    <div class="field">
      <%= f.label :threshold %>
      <%= f.number_field :threshold, 
                         value: alert_rule.expression['threshold'],
                         class: 'form-input' %>
    </div>

    <div class="field">
      <%= f.label :timeframe_minutes %>
      <%= f.number_field :timeframe_minutes,
                         value: alert_rule.expression['timeframe_minutes'],
                         class: 'form-input' %>
    </div>
  <% end %>

<% end %>
```

## Step 6: Write Comprehensive Tests

```ruby
# spec/services/surveillance/your_custom_rule_processor_spec.rb
require 'rails_helper'

RSpec.describe Surveillance::YourCustomRuleProcessor do
  let(:processor) { described_class.new }
  let(:user) { create(:user) }
  let(:security) { create(:security, ticker: 'EQTY') }
  
  let(:rule) do
    create(:alert_rule,
      rule_type: 'your_custom_rule',
      severity: 'high',
      expression: {
        'threshold' => 10,
        'timeframe_minutes' => 60
      }
    )
  end

  describe '#process' do
    context 'when rule is violated' do
      it 'creates an alert event' do
        event = {
          type: 'order',
          id: 123,
          user_id: user.id,
          security_id: security.id,
          quantity: 1000
        }

        # Create historical data that will trigger the rule
        create_list(:order, 11, 
          user: user,
          security: security,
          created_at: 30.minutes.ago
        )

        expect {
          processor.process(event, rule)
        }.to change(AlertEvent, :count).by(1)

        alert = AlertEvent.last
        expect(alert.severity).to eq('high')
        expect(alert.payload['user_id']).to eq(user.id)
      end
    end

    context 'when rule is not violated' do
      it 'does not create an alert' do
        event = {
          type: 'order',
          id: 123,
          user_id: user.id,
          security_id: security.id,
          quantity: 100
        }

        expect {
          processor.process(event, rule)
        }.not_to change(AlertEvent, :count)
      end
    end
  end

  describe 'edge cases' do
    it 'handles missing event data gracefully' do
      event = { type: 'order' }
      
      expect {
        processor.process(event, rule)
      }.not_to raise_error
    end

    it 'handles invalid threshold values' do
      rule.expression['threshold'] = -1
      event = build_event
      
      result = processor.process(event, rule)
      expect(result).to be false
    end
  end

  private

  def build_event
    {
      type: 'order',
      id: rand(1000),
      user_id: user.id,
      security_id: security.id,
      quantity: 500
    }
  end
end
```

## Step 7: Integration Testing

Test the full surveillance pipeline:

```ruby
# spec/jobs/surveillance_check_job_spec.rb
RSpec.describe SurveillanceCheckJob do
  it 'processes custom rule during surveillance check' do
    rule = create(:alert_rule, rule_type: 'your_custom_rule')
    user = create(:user)
    security = create(:security)
    
    # Create scenario that should trigger rule
    create_list(:order, 15, user: user, security: security)
    
    expect {
      described_class.perform_now
    }.to change(AlertEvent, :count)
  end
end
```

## Example: Rapid Trading Detection

Here's a complete example of a rapid trading detection rule:

```ruby
# app/services/surveillance/rapid_trading_processor.rb
module Surveillance
  class RapidTradingProcessor < BaseProcessor
    WINDOW_MINUTES = 5

    def process(event, rule)
      return false unless event[:type] == 'order'

      max_orders = rule.expression['max_orders_per_window']
      user_id = event[:user_id]
      
      recent_order_count = Order.where(
        user_id: user_id,
        created_at: WINDOW_MINUTES.minutes.ago..Time.current
      ).count

      if recent_order_count >= max_orders
        create_alert(
          event: event,
          rule: rule,
          message: "Rapid trading detected: #{recent_order_count} orders " \
                   "in #{WINDOW_MINUTES} minutes",
          details: {
            order_count: recent_order_count,
            window_minutes: WINDOW_MINUTES,
            threshold: max_orders
          }
        )
        
        # Optionally auto-restrict user
        restrict_user_trading(user_id) if rule.expression['auto_restrict']
        
        return true
      end

      false
    end

    private

    def restrict_user_trading(user_id)
      user = User.find(user_id)
      user.update!(trading_restricted: true)
      
      # Notify compliance team
      ComplianceMailer.trading_restricted(user).deliver_later
    end
  end
end
```

## Configuration Examples

### Large Order Detection

```ruby
AlertRule.create!(
  name: 'Large Order Alert',
  rule_type: 'large_order',
  severity: 'high',
  enabled: true,
  expression: {
    'threshold' => 1_000_000, # KES
    'currency' => 'KES'
  }
)
```

### Wash Trading Detection

```ruby
AlertRule.create!(
  name: 'Wash Trading Detection',
  rule_type: 'wash_trading',
  severity: 'critical',
  enabled: true,
  expression: {
    'time_window_minutes' => 30,
    'min_round_trips' => 5,
    'price_tolerance' => 0.01 # 1% price difference
  }
)
```

### Custom Rule

```ruby
AlertRule.create!(
  name: 'Your Custom Alert',
  rule_type: 'your_custom_rule',
  severity: 'medium',
  enabled: true,
  expression: {
    'threshold' => 10,
    'timeframe_minutes' => 60,
    'custom_param' => 'value'
  }
)
```

## Best Practices

### Performance
- Use database indexes for time-based queries
- Cache frequently accessed data
- Consider using Redis for temporary counters
- Batch process historical data

### Accuracy
- Tune thresholds based on market conditions
- Implement different thresholds per security type
- Account for corporate actions and market events
- Review false positives regularly

### Compliance
- Log all rule executions
- Maintain audit trail of rule changes
- Document detection logic clearly
- Regular review with compliance team

## Monitoring

Track rule effectiveness:

```ruby
# Check rule hit rate
AlertRule.includes(:alert_events)
  .where(rule_type: 'your_custom_rule')
  .map { |r| [r.name, r.alert_events.count] }

# Check false positive rate
AlertEvent.where(rule_type: 'your_custom_rule', resolved: true)
  .group(:resolution_status)
  .count
```

## Troubleshooting

### Rule not triggering
- Verify rule is enabled
- Check expression parameters are correct
- Review processor registration
- Test processor logic in isolation
- Check surveillance job is running

### Too many false positives
- Adjust threshold values
- Add additional filters
- Implement smarter pattern detection
- Consider market context

### Performance issues
- Add database indexes
- Reduce lookback window
- Optimize queries
- Consider caching

## Additional Resources

- Base processor: `app/services/surveillance/base_processor.rb`
- Surveillance engine: `app/services/surveillance/engine.rb`
- AlertRule model: `app/models/alert_rule.rb`
- AlertEvent model: `app/models/alert_event.rb`
