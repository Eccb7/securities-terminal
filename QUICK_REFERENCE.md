# 🎯 Quick Reference - React Frontend

## 🚀 Start Development

```bash
# Terminal 1: Watch for changes
npm run dev

# Terminal 2: Rails server
rails server

# Access app at http://localhost:3000
```

## 📁 File Locations

```
app/javascript/
├── application.tsx          # Entry point
├── App.tsx                  # Router & routes
├── components/              # React components
│   ├── layout/             # Navbar, Layout
│   ├── dashboard/          # ✅ Dashboard (working)
│   ├── securities/         # ✅ Securities (working)
│   ├── orders/             # 📝 TODO
│   ├── portfolios/         # 📝 TODO
│   ├── watchlists/         # 📝 TODO
│   ├── news/               # 📝 TODO
│   └── alerts/             # 📝 TODO
├── services/
│   ├── apiClient.ts        # HTTP client
│   ├── api.ts              # API methods
│   └── actionCable.ts      # WebSocket
├── hooks/
│   └── useAuth.ts          # Authentication
├── stores/
│   └── authStore.ts        # Auth state
└── types/
    └── index.ts            # TypeScript types
```

## 🔌 API Endpoints

All endpoints under `/api/v1/`:

```
Dashboard:    GET /api/v1/dashboard
User:         GET /api/v1/current_user
Securities:   GET /api/v1/securities
              GET /api/v1/securities/:id
Orders:       GET /api/v1/orders
              POST /api/v1/orders
              POST /api/v1/orders/:id/cancel
Portfolios:   GET /api/v1/portfolios
              GET /api/v1/portfolios/:id
Watchlists:   GET /api/v1/watchlists
              GET /api/v1/watchlists/:id
News:         GET /api/v1/news_items
              GET /api/v1/news_items/:id
Alerts:       GET /api/v1/alert_rules
              POST /api/v1/alert_rules
```

## 📝 Component Pattern

```typescript
import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { myApi } from '@/services/api';

const MyComponent: React.FC = () => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['myData'],
    queryFn: () => myApi.getData(),
  });

  if (isLoading) return <LoadingSpinner />;
  if (error) return <div>Error loading data</div>;

  return <div>{/* Render data */}</div>;
};

export default MyComponent;
```

## 🔐 Authentication

```typescript
import { useAuth } from '@/hooks/useAuth';

const MyComponent: React.FC = () => {
  const { user, isAuthenticated, signOut } = useAuth();

  if (!isAuthenticated) return <div>Please login</div>;

  return (
    <div>
      <p>Hello, {user.email}</p>
      <button onClick={signOut}>Sign Out</button>
    </div>
  );
};
```

## 🌐 WebSocket

```typescript
import { useEffect } from 'react';
import { actionCableService } from '@/services/actionCable';

const MyComponent: React.FC = () => {
  useEffect(() => {
    // Subscribe to market quotes
    actionCableService.subscribeToMarket(['SCOM'], (data) => {
      console.log('Quote update:', data);
    });

    // Cleanup
    return () => {
      actionCableService.unsubscribeAll();
    };
  }, []);

  return <div>Real-time data</div>;
};
```

## 🎨 Tailwind Classes

```html
<!-- Card -->
<div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
  
<!-- Button -->
<button className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded text-white">
  
<!-- Input -->
<input className="w-full px-4 py-2 bg-gray-900 border border-gray-700 rounded text-white" />

<!-- Table -->
<table className="w-full">
  <thead>
    <tr className="border-b border-gray-800">
      <th className="px-4 py-3 text-left">Header</th>
    </tr>
  </thead>
  <tbody>
    <tr className="border-b border-gray-800">
      <td className="px-4 py-3">Cell</td>
    </tr>
  </tbody>
</table>
```

## 🛠️ Common Commands

```bash
# Build for production
npm run build

# Watch mode (dev)
npm run watch

# Build CSS
npm run build:css

# Development (concurrent)
npm run dev

# Check for errors
npm run build 2>&1 | grep error
```

## 🔍 Debugging

```bash
# Check Rails logs
tail -f log/development.log

# Check build output
npm run build

# Test API endpoint
curl http://localhost:3000/api/v1/dashboard

# Check routes
rails routes | grep api
```

## 📚 Import Aliases

```typescript
import { User } from '@/types';                    // types/index.ts
import { apiClient } from '@/services/apiClient'; // services/apiClient.ts
import { useAuth } from '@/hooks/useAuth';        // hooks/useAuth.ts
import { Button } from '@/components/common';     // components/common/Button.tsx
```

## ✅ Working Features

- ✅ Dashboard with stats and activity
- ✅ Securities list with search and filters
- ✅ Security detail with quotes
- ✅ Authentication flow
- ✅ Real-time WebSocket ready
- ✅ API endpoints (all created)

## 📝 TODO Features

- [ ] Orders management
- [ ] Portfolios with P&L
- [ ] Watchlists
- [ ] News feed
- [ ] Alerts system
- [ ] Reusable components
- [ ] Custom hooks for data

## 🐛 Common Issues

**Build fails:**
```bash
rm -rf app/assets/builds/*
npm run build
```

**TypeScript errors:**
- Use `@/` for imports
- Check tsconfig.json

**API not working:**
- Check Rails server running
- Check authentication
- Check Rails logs

**React not loading:**
- Run `npm run build`
- Check browser console

## 📖 Full Documentation

- `MIGRATION_COMPLETE.md` - Complete migration guide
- `REACT_GUIDE.md` - Comprehensive technical guide
- `NEXT_STEPS.md` - Detailed TODO list
- `REACT_README.md` - Quick start guide

---

**Need Help?** Check the working components (`Dashboard.tsx`, `SecuritiesList.tsx`) for examples!
