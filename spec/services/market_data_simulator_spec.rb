# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarketDataSimulator do
  describe '.generate_quotes_for_all_securities' do
    let!(:security1) { create(:security, ticker: 'EQTY') }
    let!(:security2) { create(:security, ticker: 'KCB') }
    let!(:suspended_security) { create(:security, :suspended) }

    it 'generates quotes for all active securities' do
      expect {
        described_class.generate_quotes_for_all_securities
      }.to change { MarketQuote.count }.by(2)
    end

    it 'does not generate quotes for suspended securities' do
      described_class.generate_quotes_for_all_securities
      expect(suspended_security.market_quotes.count).to eq(0)
    end

    it 'creates quotes with required fields' do
      described_class.generate_quotes_for_all_securities
      quote = security1.latest_quote

      expect(quote.bid).to be_present
      expect(quote.ask).to be_present
      expect(quote.last_price).to be_present
      expect(quote.volume).to be > 0
      expect(quote.timestamp).to be_present
    end

    it 'creates quotes with ask greater than bid' do
      described_class.generate_quotes_for_all_securities
      quote = security1.latest_quote

      expect(quote.ask).to be > quote.bid
    end
  end

  describe '.generate_quote' do
    let(:security) { create(:security) }
    let!(:previous_quote) { create(:market_quote, security: security, last_price: 100.0, timestamp: 1.minute.ago) }

    it 'generates a new quote for the security' do
      expect {
        described_class.generate_quote(security)
      }.to change { security.market_quotes.count }.by(1)
    end

    it 'prices change gradually from previous quote' do
      described_class.generate_quote(security)
      new_quote = security.latest_quote

      # Price should be within reasonable range of previous price (±5%)
      price_change_percentage = ((new_quote.last_price - previous_quote.last_price) / previous_quote.last_price * 100).abs
      expect(price_change_percentage).to be < 5
    end

    it 'generates quote with proper spread' do
      described_class.generate_quote(security)
      quote = security.latest_quote

      spread = quote.ask - quote.bid
      expect(spread).to be > 0
      expect(spread).to be < quote.last_price * 0.05 # Spread less than 5% of price
    end

    context 'when there is no previous quote' do
      let(:new_security) { create(:security) }

      it 'generates initial quote with base price' do
        described_class.generate_quote(new_security)
        quote = new_security.latest_quote

        expect(quote.last_price).to be_between(20, 200)
      end
    end
  end
end
