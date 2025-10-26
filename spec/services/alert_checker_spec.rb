# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertChecker do
  describe '.check_all_active_alerts' do
    let(:user) { create(:user) }
    let(:security) { create(:security) }
    let!(:current_quote) { create(:market_quote, security: security, last_price: 105.0, volume: 15000) }

    let!(:price_alert_triggered) do
      create(:alert_rule,
        user: user,
        security: security,
        condition_type: 'price',
        comparison_operator: 'greater_than',
        threshold_value: 100.0,
        status: 'active'
      )
    end

    let!(:price_alert_not_triggered) do
      create(:alert_rule,
        user: user,
        security: security,
        condition_type: 'price',
        comparison_operator: 'greater_than',
        threshold_value: 110.0,
        status: 'active'
      )
    end

    let!(:inactive_alert) do
      create(:alert_rule,
        user: user,
        security: security,
        status: 'inactive'
      )
    end

    it 'checks all active alerts' do
      described_class.check_all_active_alerts

      price_alert_triggered.reload
      price_alert_not_triggered.reload
      inactive_alert.reload

      expect(price_alert_triggered.status).to eq('triggered')
      expect(price_alert_not_triggered.status).to eq('active')
      expect(inactive_alert.status).to eq('inactive')
    end

    it 'creates alert events for triggered alerts' do
      expect {
        described_class.check_all_active_alerts
      }.to change { AlertEvent.count }.by(1)

      event = price_alert_triggered.alert_events.last
      expect(event.actual_value).to eq(105.0)
      expect(event.status).to eq('pending')
    end

    it 'does not trigger the same alert multiple times within cooldown period' do
      # First trigger
      described_class.check_all_active_alerts
      expect(price_alert_triggered.reload.status).to eq('triggered')

      # Reset to active
      price_alert_triggered.update!(status: 'active')

      # Create another event less than 15 minutes ago
      price_alert_triggered.alert_events.create!(
        triggered_at: 10.minutes.ago,
        actual_value: 105.0,
        status: 'pending',
        message: 'Previous trigger'
      )

      # Try to trigger again
      expect {
        described_class.check_all_active_alerts
      }.not_to change { price_alert_triggered.alert_events.count }
    end
  end

  describe '.check_alerts_for_security' do
    let(:user) { create(:user) }
    let(:security) { create(:security) }
    let!(:current_quote) { create(:market_quote, security: security, last_price: 105.0, volume: 15000) }

    context 'with price alerts' do
      let!(:alert) do
        create(:alert_rule,
          user: user,
          security: security,
          condition_type: 'price',
          comparison_operator: 'greater_than',
          threshold_value: 100.0,
          status: 'active'
        )
      end

      it 'triggers price alert when condition is met' do
        described_class.check_alerts_for_security(security)

        alert.reload
        expect(alert.status).to eq('triggered')
      end
    end

    context 'with volume alerts' do
      let!(:alert) do
        create(:alert_rule,
          user: user,
          security: security,
          condition_type: 'volume',
          comparison_operator: 'greater_than',
          threshold_value: 10000.0,
          status: 'active'
        )
      end

      it 'triggers volume alert when condition is met' do
        described_class.check_alerts_for_security(security)

        alert.reload
        expect(alert.status).to eq('triggered')
      end
    end

    context 'with percent_change alerts' do
      let!(:old_quote) { create(:market_quote, security: security, last_price: 100.0, timestamp: 1.day.ago) }
      let!(:alert) do
        create(:alert_rule,
          user: user,
          security: security,
          condition_type: 'percent_change',
          comparison_operator: 'greater_than',
          threshold_value: 3.0,
          status: 'active'
        )
      end

      it 'triggers percent change alert when condition is met' do
        described_class.check_alerts_for_security(security)

        alert.reload
        expect(alert.status).to eq('triggered')
      end
    end

    context 'with less_than operator' do
      let!(:alert) do
        create(:alert_rule,
          user: user,
          security: security,
          condition_type: 'price',
          comparison_operator: 'less_than',
          threshold_value: 100.0,
          status: 'active'
        )
      end

      it 'does not trigger when value is above threshold' do
        described_class.check_alerts_for_security(security)

        alert.reload
        expect(alert.status).to eq('active')
      end
    end
  end
end
