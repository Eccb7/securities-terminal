# Contributing to Kenya Securities Terminal

Thank you for your interest in contributing to the Kenya Securities Terminal! This document provides guidelines and workflows for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Project Structure](#project-structure)

## Code of Conduct

This project follows a professional code of conduct. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites

- Ruby 3.2.3+
- PostgreSQL 14+
- Redis 6+
- Node.js 18+
- Git

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/kenya-securities-terminal.git
   cd kenya-securities-terminal
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/Eccb7/kenya-securities-terminal.git
   ```

4. Run setup script:
   ```bash
   ./bin/setup-terminal
   ```

5. Copy and configure environment:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

## Development Workflow

### 1. Check the Roadmap

Review `ROADMAP.md` to understand:
- Current phase and priorities
- Available tasks
- Project status

### 2. Create a Feature Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `test/` - Test additions/improvements

### 3. Make Your Changes

- Write clean, maintainable code
- Follow coding standards (see below)
- Add tests for new functionality
- Update documentation as needed

### 4. Run Tests and Linters

```bash
# Run all tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Run security scan
bin/brakeman

# Fix auto-fixable issues
bundle exec rubocop -a
```

### 5. Commit Your Changes

Follow commit message guidelines (see below).

```bash
git add .
git commit -m "feat: add market data simulator"
```

### 6. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Coding Standards

### Ruby Style Guide

We follow the [Ruby Style Guide](https://rubystyle.guide/) enforced by Rubocop.

Key points:
- Use 2 spaces for indentation (no tabs)
- Keep lines under 120 characters
- Use snake_case for methods and variables
- Use CamelCase for classes and modules
- Prefer `do...end` for multi-line blocks
- Prefer `{...}` for single-line blocks

### Rails Conventions

- Follow Rails naming conventions
- Keep controllers thin, models fat
- Use service objects for complex business logic
- Use concerns for shared behavior
- Put background jobs in `app/jobs/`
- Put services in `app/services/`

### Example: Good Code

```ruby
# Good
class PortfolioService
  def initialize(portfolio)
    @portfolio = portfolio
  end

  def calculate_pnl
    positions.sum do |position|
      (current_price(position) - position.avg_price) * position.quantity
    end
  end

  private

  def positions
    @positions ||= @portfolio.positions.includes(:security)
  end

  def current_price(position)
    MarketQuote.latest_price(position.security_id)
  end
end
```

### Example: Bad Code

```ruby
# Bad - too much logic in controller
class PortfoliosController < ApplicationController
  def show
    @portfolio = Portfolio.find(params[:id])
    @pnl = 0
    @portfolio.positions.each do |position|
      price = MarketQuote.where(security_id: position.security_id).order(timestamp: :desc).first.last_price
      @pnl += (price - position.avg_price) * position.quantity
    end
  end
end
```

## Testing Requirements

### Test Coverage

- Aim for 85%+ test coverage
- All new features must have tests
- All bug fixes must have regression tests

### Test Types

1. **Model Tests** - Test validations, associations, scopes
   ```ruby
   RSpec.describe User, type: :model do
     it { should validate_presence_of(:email) }
     it { should belong_to(:organization) }
     
     describe "#trader?" do
       it "returns true for trader role" do
         user = create(:user, role: :trader)
         expect(user.trader?).to be true
       end
     end
   end
   ```

2. **Request Tests** - Test controllers and APIs
   ```ruby
   RSpec.describe "Securities API", type: :request do
     describe "GET /api/v1/securities/:ticker" do
       it "returns security details" do
         security = create(:security, ticker: "EQTY")
         get api_v1_security_path(security.ticker)
         
         expect(response).to have_http_status(:success)
         expect(json_response["ticker"]).to eq("EQTY")
       end
     end
   end
   ```

3. **Service Tests** - Test business logic
   ```ruby
   RSpec.describe PortfolioService do
     describe "#calculate_pnl" do
       it "calculates portfolio profit and loss" do
         portfolio = create(:portfolio)
         service = described_class.new(portfolio)
         
         pnl = service.calculate_pnl
         expect(pnl).to be_a(Numeric)
       end
     end
   end
   ```

4. **Feature Tests** - Test user workflows
   ```ruby
   RSpec.describe "User places order", type: :feature do
     it "allows authenticated user to place order" do
       user = create(:user)
       security = create(:security)
       
       login_as(user)
       visit new_order_path
       
       fill_in "Quantity", with: 100
       select security.ticker, from: "Security"
       click_button "Place Order"
       
       expect(page).to have_content("Order placed successfully")
     end
   end
   ```

### Using Factories

Create factories for test data:

```ruby
# spec/factories/securities.rb
FactoryBot.define do
  factory :security do
    ticker { "EQTY" }
    name { "Equity Group Holdings" }
    instrument_type { "equity" }
    currency { "KES" }
    exchange
  end
end

# Usage in tests
security = create(:security)
securities = create_list(:security, 5)
security = build(:security)  # Without saving
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
# Feature
git commit -m "feat(market-data): add NSE adapter for live quotes"

# Bug fix
git commit -m "fix(orders): prevent duplicate order submission"

# Documentation
git commit -m "docs(api): add examples for order placement endpoint"

# Test
git commit -m "test(portfolio): add tests for P&L calculation"

# Refactor
git commit -m "refactor(matching-engine): extract order book to separate class"
```

### Good Commit Messages

- Use present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor to..." not "moves cursor to...")
- Keep first line under 72 characters
- Reference issues and PRs when relevant

## Pull Request Process

### Before Submitting

- [ ] Tests pass locally (`bundle exec rspec`)
- [ ] Linter passes (`bundle exec rubocop`)
- [ ] Security scan passes (`bin/brakeman`)
- [ ] Documentation updated (if needed)
- [ ] CHANGELOG updated (if significant change)
- [ ] Self-review of code completed

### PR Template

When creating a PR, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How to test these changes

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Linter passes
- [ ] Self-reviewed code
- [ ] No console.log or debugger statements

## Screenshots (if applicable)
```

### Review Process

1. Automated checks run (GitHub Actions CI)
2. Code review by maintainer(s)
3. Address feedback
4. Get approval
5. Squash and merge

### After Merge

1. Delete your feature branch
2. Update your local main:
   ```bash
   git checkout main
   git pull upstream main
   ```

## Project Structure

### Key Directories

```
app/
├── models/          # ActiveRecord models
├── controllers/     # Request handlers
├── services/        # Business logic
├── jobs/            # Background jobs
├── channels/        # WebSocket channels
├── policies/        # Authorization policies
└── views/           # HTML templates

lib/
└── market_data/     # Market data adapters

spec/
├── models/
├── requests/
├── services/
├── features/
├── factories/
└── support/

docs/                # Developer guides
```

### Adding New Features

#### New Model

```bash
# Generate model
rails g model Security ticker:string name:string

# Edit migration
# Add validations and associations in model
# Create factory
# Write tests
# Run migration
rails db:migrate
```

#### New Service

```ruby
# app/services/market_data/normalizer.rb
module MarketData
  class Normalizer
    def normalize(raw_data)
      # Implementation
    end
  end
end

# spec/services/market_data/normalizer_spec.rb
RSpec.describe MarketData::Normalizer do
  # Tests
end
```

#### New Job

```bash
# Generate job
rails g job MarketDataIngestion

# Implement in app/jobs/market_data_ingestion_job.rb
# Write tests in spec/jobs/market_data_ingestion_job_spec.rb
```

#### New API Endpoint

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :securities, only: [:index, :show]
  end
end

# app/controllers/api/v1/securities_controller.rb
# spec/requests/api/v1/securities_spec.rb
```

## Additional Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [RSpec Documentation](https://rspec.info/)
- [Ruby Style Guide](https://rubystyle.guide/)
- [Git Workflow](https://guides.github.com/introduction/flow/)

## Getting Help

- Check `docs/` for guides
- Review `ROADMAP.md` for current priorities
- Search existing issues and PRs
- Ask questions in PR comments

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

**Thank you for contributing to Kenya Securities Terminal!** 🎉
