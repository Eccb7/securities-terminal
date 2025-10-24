# Kenya Securities Terminal - Development Roadmap

## Project Status: Phase 1 - Foundation ✅

Last Updated: October 24, 2025

---

## ✅ Completed Tasks

### Phase 1: Project Foundation
- [x] Rails 8 application initialized
- [x] Project structure created
- [x] Essential gems added to Gemfile:
  - devise (authentication)
  - pundit (authorization)
  - rspec-rails (testing)
  - sidekiq (background jobs)
  - redis (caching/jobs)
  - hotwire-rails (real-time UI)
  - faraday (API client)
  - chartkick (charts)
  - lockbox (encryption)
- [x] Docker Compose configuration created
- [x] Environment variable template (.env.example)
- [x] Sidekiq configuration with job queues
- [x] GitHub Actions CI pipeline configured
- [x] Comprehensive README with architecture
- [x] Developer documentation:
  - Adding Market Data Adapters
  - Adding Surveillance Rules
- [x] Setup script created (bin/setup-terminal)

---

## 🔄 Current Sprint: Authentication & Authorization

### Phase 2: User Management
- [ ] Install and configure Devise
- [ ] Generate User model with fields:
  - email, encrypted_password
  - name, role (enum)
  - two_fa_secret, two_fa_enabled
  - organization_id
  - last_sign_in_at
  - trading_restricted
- [ ] Generate Organization model:
  - name, admin_user_id
  - settings (jsonb)
  - created_at, updated_at
- [ ] Install and configure Pundit
- [ ] Create policy files for all models
- [ ] Implement role-based access control (RBAC):
  - super_admin: full system access
  - admin: organization management
  - trader: trading operations
  - compliance_officer: surveillance & audit
  - analyst: read-only + reports
  - viewer: read-only
- [ ] Add 2FA support with ROTP gem
- [ ] Create authentication controllers and views
- [ ] Write tests for authentication flows
- [ ] Write tests for authorization policies

---

## 📅 Upcoming Phases

### Phase 3: Core Market Data Models (Week 2)
- [ ] Security model with validations
- [ ] Exchange model
- [ ] MarketQuote model with table partitioning
- [ ] Admin interface for securities management
- [ ] Seed script with Kenyan securities
- [ ] Tests for all models

### Phase 4: Market Data Ingestion (Week 2-3)
- [ ] Create adapter base class
- [ ] Implement NSE adapter (primary)
- [ ] Implement AlphaVantage adapter (fallback)
- [ ] Implement CSV adapter (historical)
- [ ] Create normalizer service
- [ ] Create market simulator job
- [ ] Background jobs for data ingestion
- [ ] Tests for adapters and ingestion

### Phase 5: Real-time UI Foundation (Week 3)
- [ ] Setup Action Cable channels:
  - MarketChannel
  - OrderChannel
  - NewsChannel
  - AlertChannel
- [ ] Create Stimulus controllers for UI
- [ ] Implement Turbo Streams for updates
- [ ] Create base terminal layout
- [ ] Ticker tape component
- [ ] Quote panel component
- [ ] Tests for channels and components

### Phase 6: Trading System (Week 4)
- [ ] Order model with status tracking
- [ ] Trade model
- [ ] Matching engine service
- [ ] Order book implementation
- [ ] Order entry UI
- [ ] Order blotter UI
- [ ] Trade confirmation
- [ ] Paper trading toggle
- [ ] Tests for matching engine

### Phase 7: Portfolio Management (Week 5)
- [ ] Portfolio model
- [ ] Position model
- [ ] Portfolio service for calculations
- [ ] P&L calculation service
- [ ] VaR calculator (95% parametric)
- [ ] Portfolio dashboard UI
- [ ] Position tracking
- [ ] Tests for portfolio calculations

### Phase 8: Compliance & Surveillance (Week 5-6)
- [ ] AuditLog model
- [ ] AlertRule model
- [ ] AlertEvent model
- [ ] Surveillance engine
- [ ] Rule processors:
  - Large order detection
  - Rapid trading
  - Wash trading
  - Front running
- [ ] Compliance dashboard
- [ ] Alert management UI
- [ ] Tests for surveillance

### Phase 9: News & Research (Week 6)
- [ ] NewsItem model with full-text search
- [ ] News ingestion job
- [ ] RSS/API feed parsers
- [ ] Security tagging
- [ ] News feed UI
- [ ] Search functionality
- [ ] Tests for news system

### Phase 10: Advanced UI (Week 7)
- [ ] Resizable panel layout
- [ ] Drag-and-drop functionality
- [ ] Keyboard shortcuts
- [ ] Chart component with TradingView
- [ ] Technical indicators
- [ ] Dark/light theme toggle
- [ ] Accessibility improvements (ARIA)
- [ ] Mobile responsive design

### Phase 11: Testing & Quality (Week 8)
- [ ] Comprehensive model tests
- [ ] Controller/request tests
- [ ] Service object tests
- [ ] Feature/integration tests
- [ ] System tests with Capybara
- [ ] Test factories for all models
- [ ] Code coverage > 85%
- [ ] Performance testing

### Phase 12: Deployment & Documentation (Week 9)
- [ ] Production Dockerfile optimization
- [ ] Docker Compose production config
- [ ] Kubernetes manifests (optional)
- [ ] AWS deployment guide
- [ ] Heroku deployment guide
- [ ] Database backup strategy
- [ ] Monitoring setup
- [ ] Final documentation review

---

## 🎯 Success Criteria

### Minimum Viable Product (MVP)
- ✅ User can sign up and log in
- [ ] User can view real-time quotes
- [ ] User can place paper trades
- [ ] User can view portfolio P&L
- [ ] Admin can manage securities
- [ ] System logs audit trail
- [ ] Tests pass in CI

### Production Ready
- [ ] All features implemented
- [ ] Test coverage > 85%
- [ ] Security audit passed
- [ ] Performance benchmarks met
- [ ] Documentation complete
- [ ] Deployment automated
- [ ] Monitoring configured

---

## 📊 Metrics & KPIs

### Development Metrics
- Lines of Code: TBD
- Test Coverage: 0% → Target: 85%
- Code Quality: A (Rubocop)
- Security Issues: 0 (Brakeman)

### Performance Targets
- Page Load: < 2s
- Quote Update Latency: < 100ms
- Order Execution: < 500ms
- API Response Time: < 200ms
- WebSocket Latency: < 50ms

---

## 🔧 Technical Debt & Improvements

### Current Issues
- None yet

### Future Enhancements
- GraphQL API
- Mobile app (React Native)
- Advanced order types (TWAP, VWAP, Iceberg)
- Algorithmic trading support
- Social trading features
- Multiple currency support
- Derivatives trading
- Live trading integration (regulatory approval required)

---

## 📝 Notes

### Environment Setup Required
1. Ruby 3.2.3+ installed
2. PostgreSQL 14+ running
3. Redis 6+ running
4. Node.js 18+ installed
5. Environment variables configured in .env

### External Dependencies
- NSE API access (pending API key)
- AlphaVantage API key (free tier available)
- SMTP server for emails
- (Optional) ElasticSearch for news search

### Regulatory Considerations
- Paper trading only until regulatory approval
- KYC/AML compliance requirements
- Data retention policies
- Audit trail requirements
- Capital Markets Authority (CMA) regulations

---

## 🤝 Team & Responsibilities

### Current Phase Owners
- **Phase 2 (Auth)**: In Progress
- **Phase 3 (Models)**: Not Started
- **Phase 4 (Data)**: Not Started

### Code Review Requirements
- All PRs require review
- Tests must pass in CI
- Rubocop violations must be fixed
- Brakeman security checks must pass

---

## 📞 Getting Help

### Resources
- README.md - Project overview
- docs/ - Detailed guides
- .env.example - Configuration reference
- GitHub Issues - Bug tracking

### Commands
```bash
# Setup
./bin/setup-terminal

# Development
bin/dev

# Tests
bundle exec rspec

# Console
rails console

# Database
rails db:migrate
rails db:seed
```

---

**Next Step**: Run `./bin/setup-terminal` to complete local setup, then proceed with Devise installation.
