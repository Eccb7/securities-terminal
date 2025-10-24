# Adding a Market Data Adapter

This guide explains how to add a new market data provider to the Kenya Terminal.

## Overview

Market data adapters follow a common interface defined in `MarketData::Adapter::Base`. Each adapter is responsible for:

1. Establishing connection to the data source
2. Streaming real-time quotes
3. Fetching historical data
4. Normalizing data into the application format
5. Error handling and retry logic

## Step 1: Create the Adapter Class

Create a new file in `lib/market_data/adapter/`:

```ruby
# lib/market_data/adapter/your_provider_adapter.rb
module MarketData
  module Adapter
    class YourProviderAdapter < Base
      def initialize
        @api_key = ENV['YOUR_PROVIDER_API_KEY']
        @base_url = ENV['YOUR_PROVIDER_API_URL']
        @connection = build_connection
      end

      # Stream real-time quotes for given tickers
      # @param tickers [Array<String>] Array of ticker symbols
      # @yield [normalized_quote] Yields normalized quote hash
      def stream_quotes(tickers, &block)
        # Implementation for streaming quotes
        # Can use WebSocket, Server-Sent Events, or polling
        
        # Example polling implementation:
        loop do
          tickers.each do |ticker|
            quote_data = fetch_quote(ticker)
            normalized = normalize_quote(quote_data)
            yield normalized
          rescue => e
            handle_error(e, ticker)
          end
          sleep fetch_interval
        end
      end

      # Fetch historical data for a ticker
      # @param ticker [String] Ticker symbol
      # @param from [DateTime] Start date
      # @param to [DateTime] End date
      # @return [Array<Hash>] Array of normalized historical quotes
      def fetch_historical(ticker, from, to)
        response = @connection.get do |req|
          req.url "/historical/#{ticker}"
          req.params['from'] = from.iso8601
          req.params['to'] = to.iso8601
          req.params['apikey'] = @api_key
        end

        parse_historical_response(response.body)
      end

      # Check if the adapter is healthy and can connect
      # @return [Boolean] true if healthy
      def healthy?
        response = @connection.get('/health')
        response.success?
      rescue
        false
      end

      private

      def build_connection
        Faraday.new(url: @base_url) do |f|
          f.request :json
          f.request :retry, max: 3, interval: 0.5
          f.response :json
          f.adapter Faraday.default_adapter
        end
      end

      def fetch_quote(ticker)
        response = @connection.get do |req|
          req.url "/quote/#{ticker}"
          req.params['apikey'] = @api_key
        end
        response.body
      end

      def normalize_quote(raw_data)
        {
          ticker: raw_data['symbol'],
          bid: raw_data['bid']&.to_f,
          ask: raw_data['ask']&.to_f,
          last_price: raw_data['price']&.to_f,
          volume: raw_data['volume']&.to_i,
          timestamp: parse_timestamp(raw_data['timestamp']),
          high: raw_data['high']&.to_f,
          low: raw_data['low']&.to_f,
          open: raw_data['open']&.to_f,
          close: raw_data['close']&.to_f
        }
      end

      def parse_timestamp(ts)
        # Parse timestamp based on provider format
        Time.parse(ts)
      rescue
        Time.current
      end

      def parse_historical_response(body)
        body['data'].map { |record| normalize_quote(record) }
      end

      def handle_error(error, ticker)
        Rails.logger.error("Error fetching quote for #{ticker}: #{error.message}")
        # Optionally notify monitoring system
      end

      def fetch_interval
        ENV.fetch('QUOTE_FETCH_INTERVAL', 5).to_i
      end
    end
  end
end
```

## Step 2: Add Configuration

Add the necessary environment variables to `.env.example`:

```bash
# Your Provider Configuration
YOUR_PROVIDER_API_KEY=your_api_key_here
YOUR_PROVIDER_API_URL=https://api.yourprovider.com/v1
YOUR_PROVIDER_ENABLED=true
```

## Step 3: Register the Adapter

Add your adapter to the adapter registry in `config/initializers/market_data.rb`:

```ruby
# config/initializers/market_data.rb
MarketData::AdapterRegistry.register(
  :your_provider,
  MarketData::Adapter::YourProviderAdapter,
  priority: 2,  # Lower priority than primary (NSE = 1)
  enabled: ENV['YOUR_PROVIDER_ENABLED'] == 'true'
)
```

## Step 4: Write Tests

Create comprehensive tests in `spec/lib/market_data/adapter/your_provider_adapter_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe MarketData::Adapter::YourProviderAdapter do
  let(:adapter) { described_class.new }
  
  before do
    ENV['YOUR_PROVIDER_API_KEY'] = 'test_key'
    ENV['YOUR_PROVIDER_API_URL'] = 'https://api.test.com'
  end

  describe '#stream_quotes' do
    it 'yields normalized quotes for each ticker' do
      tickers = ['EQTY', 'KCB']
      quotes = []
      
      # Stub HTTP requests
      stub_request(:get, /api.test.com/).to_return(
        status: 200,
        body: { symbol: 'EQTY', price: 50.25 }.to_json
      )
      
      # Run for limited time in test
      Timeout.timeout(2) do
        adapter.stream_quotes(tickers) { |quote| quotes << quote }
      end rescue Timeout::Error
      
      expect(quotes).not_to be_empty
      expect(quotes.first).to include(:ticker, :last_price)
    end
  end

  describe '#fetch_historical' do
    it 'returns array of historical quotes' do
      stub_request(:get, /api.test.com\/historical/).to_return(
        status: 200,
        body: { data: [{ symbol: 'EQTY', price: 50.0 }] }.to_json
      )
      
      from = 1.week.ago
      to = Time.current
      
      result = adapter.fetch_historical('EQTY', from, to)
      
      expect(result).to be_an(Array)
      expect(result.first[:ticker]).to eq('EQTY')
    end
  end

  describe '#healthy?' do
    it 'returns true when API is accessible' do
      stub_request(:get, 'https://api.test.com/health').to_return(status: 200)
      
      expect(adapter.healthy?).to be true
    end

    it 'returns false when API is not accessible' do
      stub_request(:get, 'https://api.test.com/health').to_timeout
      
      expect(adapter.healthy?).to be false
    end
  end
end
```

## Step 5: Integration Testing

Test the adapter with the ingestion pipeline:

```ruby
# spec/jobs/market_data_ingestion_job_spec.rb
RSpec.describe MarketDataIngestionJob do
  it 'ingests data from custom adapter' do
    # Setup test data
    # Run job
    # Verify MarketQuote records created
  end
end
```

## Step 6: Monitor and Validate

1. Start the application with the new adapter enabled
2. Monitor logs for successful data ingestion
3. Check database for new MarketQuote records
4. Verify data accuracy against source

```bash
# Tail logs
tail -f log/development.log | grep YourProviderAdapter

# Check recent quotes
rails console
> MarketQuote.where(source: 'your_provider').last(10)
```

## Best Practices

### Error Handling
- Always catch and log errors
- Implement exponential backoff for retries
- Don't crash the entire ingestion pipeline on one adapter failure

### Rate Limiting
- Respect API rate limits
- Implement request throttling if needed
- Use bulk requests when available

### Data Quality
- Validate data before persisting
- Handle missing or null fields gracefully
- Detect and flag stale data

### Performance
- Use connection pooling
- Batch database inserts
- Consider async processing for historical data

### Security
- Never commit API keys
- Use environment variables for all credentials
- Implement request signing if required by provider

## Adapter Priority System

Adapters are tried in priority order (1 = highest):

1. **NSE Adapter** (priority: 1) - Primary source for Kenyan securities
2. **Your Adapter** (priority: 2) - Your custom adapter
3. **AlphaVantage** (priority: 3) - Fallback for international securities

The system will try each adapter in order until one successfully returns data.

## Troubleshooting

### Adapter not receiving data
- Check API credentials in environment variables
- Verify API endpoint URLs are correct
- Test connectivity: `curl https://api.yourprovider.com/health`
- Check adapter is enabled in config
- Review logs for error messages

### Data not persisting
- Verify normalization format matches expected schema
- Check for validation errors in MarketQuote model
- Ensure security records exist for tickers
- Review database constraints

### Performance issues
- Profile the adapter code
- Implement caching where appropriate
- Reduce fetch frequency if rate limited
- Consider using websockets instead of polling

## Additional Resources

- Base adapter interface: `lib/market_data/adapter/base.rb`
- NSE adapter reference: `lib/market_data/adapter/nse_adapter.rb`
- Normalizer service: `app/services/market_data/normalizer.rb`
- Ingestion job: `app/jobs/market_data_ingestion_job.rb`

## Support

For questions or issues:
- Check existing adapter implementations
- Review test coverage
- Consult API documentation for your provider
- Open an issue on GitHub
