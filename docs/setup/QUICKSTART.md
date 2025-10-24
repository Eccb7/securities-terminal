# Quick Start Guide - Kenya Securities Terminal

## 🚀 Get Started in 5 Minutes

### Prerequisites Check
```bash
ruby --version    # Need 3.2.3+
node --version    # Need 18+
psql --version    # Need PostgreSQL 14+
redis-cli ping    # Should return PONG
```

### Installation
```bash
# 1. Install dependencies & setup database
./bin/setup-terminal

# 2. Configure environment
cp .env.example .env
# Edit .env with your settings

# 3. Start the application
bin/dev
```

### Access
- **Web**: http://localhost:3000
- **Sidekiq**: http://localhost:3000/sidekiq (admin only)
- **API**: http://localhost:3000/api/v1

---

## 📁 Project Structure Quick Reference

```
app/
├── models/          # Database models
├── controllers/     # HTTP request handlers
├── services/        # Business logic
├── jobs/            # Background jobs (Sidekiq)
├── channels/        # WebSocket channels (Action Cable)
├── views/           # HTML templates
└── javascript/      # Stimulus controllers

lib/
└── market_data/     # Market data adapters
    └── adapter/     # NSE, AlphaVantage, etc.

spec/                # RSpec tests
config/              # Rails configuration
docs/                # Developer guides
```

---

## 🔑 Key Files

| File | Purpose |
|------|---------|
| `Gemfile` | Ruby dependencies |
| `.env` | Environment configuration |
| `config/database.yml` | Database settings |
| `config/sidekiq.yml` | Background job configuration |
| `docker-compose.yml` | Docker services |
| `ROADMAP.md` | Development progress |
| `README.md` | Full documentation |

---

## 🛠️ Common Commands

### Development
```bash
bin/dev              # Start Rails + Sidekiq + assets
rails console        # Interactive console
rails server         # Rails server only
bundle exec sidekiq  # Background jobs only
```

### Database
```bash
rails db:create      # Create database
rails db:migrate     # Run migrations
rails db:seed        # Load seed data
rails db:reset       # Drop, create, migrate, seed
rails db:rollback    # Undo last migration
```

### Testing
```bash
bundle exec rspec                    # All tests
bundle exec rspec spec/models/       # Model tests only
bundle exec rspec spec/path/file_spec.rb  # Specific file
COVERAGE=true bundle exec rspec      # With coverage
```

### Code Quality
```bash
bundle exec rubocop              # Lint all files
bundle exec rubocop -a           # Auto-fix issues
bin/brakeman                     # Security scan
bundle exec rubocop --auto-gen-config  # Generate config
```

### Generators
```bash
rails g model Security ticker:string name:string
rails g controller Securities index show
rails g migration AddFieldToTable field:type
rails g job MarketDataIngestion
rails g channel Market
rails g stimulus ticker
```

---

## 🎯 Current Phase: Authentication

### Next Steps
1. Install Devise
   ```bash
   bundle exec rails generate devise:install
   bundle exec rails generate devise User
   ```

2. Add User fields (edit generated migration):
   ```ruby
   add_column :users, :name, :string
   add_column :users, :role, :integer, default: 0
   add_column :users, :two_fa_secret, :string
   add_column :users, :two_fa_enabled, :boolean, default: false
   add_column :users, :organization_id, :integer
   add_column :users, :trading_restricted, :boolean, default: false
   ```

3. Create Organization model
   ```bash
   rails g model Organization name:string admin_user_id:integer settings:jsonb
   ```

4. Setup Pundit
   ```bash
   bundle exec rails generate pundit:install
   ```

---

## 📦 Key Gems

| Gem | Purpose | Version |
|-----|---------|---------|
| devise | Authentication | ~> 4.9 |
| pundit | Authorization | ~> 2.3 |
| sidekiq | Background jobs | ~> 7.2 |
| rspec-rails | Testing | ~> 7.1 |
| hotwire-rails | Real-time UI | Latest |
| faraday | HTTP client | ~> 2.9 |
| chartkick | Charts | ~> 5.0 |

---

## 🔍 Debugging

### Common Issues

**Bundle install fails**
```bash
# Try system Ruby instead
/usr/bin/gem install bundler
/usr/bin/bundle install
```

**Database connection error**
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql
# Check config/database.yml
```

**Redis connection error**
```bash
# Check Redis is running
sudo systemctl status redis
# Or via Docker
docker ps | grep redis
```

**Assets not compiling**
```bash
npm install
rails assets:precompile
```

---

## 🐳 Docker Commands

```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f web
docker-compose logs -f sidekiq

# Stop services
docker-compose down

# Rebuild
docker-compose build
docker-compose up --build

# Database commands
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed

# Shell access
docker-compose exec web bash
docker-compose exec db psql -U postgres
```

---

## 🧪 Testing Quick Reference

### Test Structure
```ruby
# Model test
RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should belong_to(:organization) }
end

# Controller test
RSpec.describe SecuritiesController, type: :request do
  describe "GET /securities" do
    it "returns success" do
      get securities_path
      expect(response).to have_http_status(:success)
    end
  end
end

# Feature test
RSpec.describe "User login", type: :feature do
  it "allows user to sign in" do
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"
    expect(page).to have_content("Signed in successfully")
  end
end
```

### Factories
```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    name { Faker::Name.name }
    role { :trader }
    organization
  end
end

# Usage
user = create(:user)
users = create_list(:user, 5)
user = build(:user)  # Without saving
```

---

## 🔐 Security Checklist

- [ ] All secrets in .env (not committed)
- [ ] Strong passwords enforced
- [ ] 2FA enabled for admin users
- [ ] HTTPS in production
- [ ] CSRF protection enabled
- [ ] SQL injection prevention (use params)
- [ ] XSS protection (escape user input)
- [ ] Rate limiting on API endpoints
- [ ] Audit logging for sensitive actions

---

## 📊 Monitoring

### Logs
```bash
tail -f log/development.log
tail -f log/sidekiq.log
grep ERROR log/production.log
```

### Performance
```bash
# In rails console
User.count
MarketQuote.count
Security.count

# Check slow queries
ActiveRecord::Base.logger = Logger.new(STDOUT)
```

### Sidekiq
```bash
# View queue status
bundle exec sidekiq-cli stats

# Clear queue
Sidekiq::Queue.new.clear

# Retry failed jobs
Sidekiq::RetrySet.new.retry_all
```

---

## 🎨 UI Development

### Stimulus
```javascript
// app/javascript/controllers/ticker_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "price" ]
  
  connect() {
    this.subscribe()
  }
  
  subscribe() {
    // Subscribe to ActionCable channel
  }
}
```

### Turbo Streams
```ruby
# Controller
def update
  @security.update(security_params)
  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to @security }
  end
end
```

```erb
<!-- update.turbo_stream.erb -->
<%= turbo_stream.replace @security do %>
  <%= render @security %>
<% end %>
```

---

## 📚 Documentation

- **Full README**: `README.md`
- **Roadmap**: `ROADMAP.md`
- **Market Adapters**: `docs/adding_market_adapter.md`
- **Surveillance Rules**: `docs/adding_surveillance_rule.md`
- **Phase 1 Summary**: `PHASE1_COMPLETE.md`

---

## 🆘 Get Help

1. Check documentation in `docs/`
2. Review ROADMAP.md for current phase
3. Search existing code for examples
4. Check Rails guides: https://guides.rubyonrails.org/

---

**Remember**: This is Phase 1. Focus on authentication next!

Run: `./bin/setup-terminal` then start coding! 🚀
