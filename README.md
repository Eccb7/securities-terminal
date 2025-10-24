# Kenya Securities Terminal

A production-ready, Bloomberg-style financial terminal specialized for the Kenyan equities and securities market. Built with Ruby on Rails, this application provides real-time market data, order management, portfolio analytics, market surveillance, news, and compliance features.

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                        Client Browser                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Ticker Tape  │  │    Chart     │  │  Order Book  │          │
│  │  & Quotes    │  │   & Depth    │  │  Time&Sales  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Order Entry  │  │    News      │  │  Portfolio   │          │
│  │  & Blotter   │  │  & Alerts    │  │    P&L       │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│              Hotwire/Turbo + Stimulus + ActionCable             │
└──────────────────────────────────────────────────────────────────┘
                              ▲ ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Rails Application                           │
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────────┐  │
│  │  Controllers   │  │    Services    │  │   Action Cable   │  │
│  │   & API        │  │   & Workers    │  │    Channels      │  │
│  └────────────────┘  └────────────────┘  └──────────────────┘  │
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────────┐  │
│  │  MarketData    │  │    Matching    │  │   Compliance     │  │
│  │   Adapters     │  │     Engine     │  │  Surveillance    │  │
│  └────────────────┘  └────────────────┘  └──────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
           ▲ ▼                    ▲ ▼                    ▲ ▼
┌─────────────────┐  ┌─────────────────┐  ┌──────────────────────┐
│   PostgreSQL    │  │      Redis      │  │      Sidekiq         │
│  (Primary DB)   │  │  (Cache/Jobs)   │  │  (Background Jobs)   │
└─────────────────┘  └─────────────────┘  └──────────────────────┘
           ▲
           │
┌─────────────────────────────────────────────────────────────────┐
│              External Market Data Sources                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │     NSE      │  │ AlphaVantage │  │  Historical CSV      │ │
│  │   (Primary)  │  │  (Fallback)  │  │     (Backfill)       │ │
│  └──────────────┘  └──────────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Features

### Core Trading Features
- **Real-time Market Data**: Live quotes, order book depth, time & sales
- **Order Management**: Market, limit, stop-limit orders with TIF options
- **Paper Trading**: Simulated matching engine for risk-free testing
- **Portfolio Analytics**: Real-time P&L, positions, VaR (95% parametric)
- **Watchlists**: Custom security watchlists with live updates

### Compliance & Risk
- **Audit Logging**: Comprehensive activity tracking
- **Market Surveillance**: Pattern detection (spoofing, large orders, unusual activity)
- **Risk Thresholds**: Position limits and exposure monitoring
- **KYC Flags**: User verification status tracking

### Data & Analytics
- **Charts**: Interactive time-series with technical indicators (SMA, EMA, RSI)
- **News Feed**: Real-time news with security tagging and full-text search
- **Historical Data**: Bulk import and backfill capabilities
- **Reports**: PDF generation for compliance and portfolio reports

### Access Control
- **Roles**: super_admin, admin, trader, compliance_officer, analyst, viewer
- **2FA**: TOTP-based two-factor authentication
- **Multi-tenancy**: Organization-level data isolation
- **OAuth2**: External authentication support (optional)

## Prerequisites

- **Ruby**: 3.2.3+ (3.3+ recommended)
- **Rails**: 8.0.2+
- **PostgreSQL**: 14+
- **Redis**: 6+
- **Node.js**: 18+ (for asset compilation)
- **Docker & Docker Compose** (for containerized deployment)

## Installation & Setup

### Local Development

1. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

2. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Start the application**
   ```bash
   bin/dev
   ```

### Docker Compose (Recommended)

```bash
docker-compose up
```

## 🔧 Configuration

See `.env.example` for all configuration options including:
- Database connections
- Market data provider API keys
- Feature flags (ENABLE_LIVE_MARKETS, ENABLE_PAPER_TRADING)
- Security settings (encryption keys)

## Core Models

- **User**: Authentication, roles, 2FA, organization membership
- **Organization**: Multi-tenant support, settings
- **Security**: Stocks, bonds, ETFs with ISIN, lot size, status
- **Exchange**: NSE configuration, timezone, trading hours
- **MarketQuote**: Real-time and historical price data (partitioned by date)
- **Order**: User orders with status tracking
- **Trade**: Matched trade records
- **Portfolio/Position**: Holdings with P&L calculation
- **Watchlist**: Custom security lists
- **NewsItem**: Market news with security tagging
- **AuditLog**: Activity tracking
- **AlertRule/AlertEvent**: Surveillance rules and alerts

## Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/models/order_spec.rb

# With coverage
COVERAGE=true bundle exec rspec
```

## Deployment

### Docker
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Heroku
```bash
heroku create kenya-terminal
heroku addons:create heroku-postgresql:standard-0
heroku addons:create heroku-redis:premium-0
git push heroku main
```

## Documentation

- Architecture: See architecture diagram above
- API Documentation: See `/docs/api.md`
- Development Guides: See `/docs/` folder
- Adding Market Adapter: See `/docs/adding_market_adapter.md`
- Adding Surveillance Rule: See `/docs/adding_surveillance_rule.md`

## Disclaimer

This software is for educational and paper trading purposes. Live trading requires regulatory approval. Users are responsible for compliance with local securities regulations.

---

**Built for the Kenyan capital markets**

