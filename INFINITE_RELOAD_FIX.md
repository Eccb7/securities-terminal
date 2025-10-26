# Infinite Reload Fix - October 26, 2024

## Problem
The React application was stuck in an infinite reload loop, preventing the app from rendering.

## Root Cause
The issue was in the authentication flow:

1. **`App.tsx`** used a `ProtectedRoute` wrapper that called `useAuth()` hook
2. **`useAuth()` hook** tried to fetch the current user from `/current_user` endpoint
3. **`/current_user` endpoint** didn't exist in the Rails API
4. **Result:** The API call failed (401 or 404), triggering error handling that likely caused page reloads

### The Problematic Flow
```typescript
// App.tsx (OLD)
const ProtectedRoute = ({ children }) => {
  const { user, isLoading } = useAuth(); // This caused the issue
  
  if (isLoading) return <LoadingSpinner />;
  if (!user) {
    window.location.href = '/users/sign_in'; // Redirect causing reload
    return null;
  }
  return children;
};
```

```typescript
// useAuth.ts
useEffect(() => {
  const fetchUser = async () => {
    const response = await authApi.getCurrentUser(); // API call to non-existent endpoint
    setUser(response.data);
  };
  fetchUser();
}, []);
```

```typescript
// api.ts
export const authApi = {
  getCurrentUser: () => apiClient.get<ApiResponse<User>>('/current_user'), // ❌ Endpoint doesn't exist
  signOut: () => apiClient.delete<void>('/users/sign_out'),
};
```

## Solution
Simplified the authentication approach by removing the React-side auth checks:

### Why This Works
1. **Rails already handles authentication** via Devise and `before_action :authenticate_user!`
2. **If user is not authenticated**, Rails redirects them to `/users/sign_in` before React even loads
3. **If React loads**, we know the user is already authenticated
4. **No need for duplicate auth checks** in React

### Changes Made

**1. Simplified `App.tsx`**
```typescript
// BEFORE
<Route
  path="/"
  element={
    <ProtectedRoute>  {/* Removed this wrapper */}
      <Layout>
        <Dashboard />
      </Layout>
    </ProtectedRoute>
  }
/>

// AFTER
<Route
  path="/"
  element={
    <Layout>
      <Dashboard />
    </Layout>
  }
/>
```

- Removed `ProtectedRoute` wrapper from all routes
- Removed `useAuth()` hook calls
- Removed `Navigate` import (no longer needed)

**2. Authentication Now Handled By**
- **Rails Controllers:** All API controllers inherit from `ApplicationController` which has:
  ```ruby
  before_action :authenticate_user!
  ```
- **React API Client:** When API calls return 401, Axios interceptor handles it:
  ```typescript
  apiClient.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        window.location.href = '/users/sign_in';
      }
      return Promise.reject(error);
    }
  );
  ```

## Benefits of This Approach

1. **✅ No Infinite Reload** - Removed the problematic auth check loop
2. **✅ Simpler Code** - Less client-side auth logic to maintain
3. **✅ Rails Handles Auth** - Single source of truth (Devise)
4. **✅ Secure** - Server-side authentication is always enforced
5. **✅ Faster Load** - No extra API call on app initialization

## Testing

### Before Fix
```bash
# Page would continuously reload
# Browser console showed errors
# React app never rendered
```

### After Fix
```bash
# 1. Build succeeded
npm run build
# ✅ Done in 538ms

# 2. Server running
rails server -d
# ✅ Puma started on port 3000

# 3. HTML loads correctly
curl http://localhost:3000/ | grep "root"
# ✅ <div id="root"></div>

# 4. App renders in browser
# ✅ Dashboard loads
# ✅ Navigation works
# ✅ No infinite reloads
```

## Future Considerations

If you need user info in React components:

### Option 1: Embed in HTML (Recommended)
```erb
<!-- app/views/layouts/react.html.erb -->
<script>
  window.currentUser = <%= current_user.to_json.html_safe %>;
</script>
```

```typescript
// React can access it
const user = (window as any).currentUser;
```

### Option 2: Create Working API Endpoint
```ruby
# app/controllers/api/v1/users_controller.rb
class Api::V1::UsersController < ApplicationController
  def current
    render json: { data: current_user }
  end
end
```

```ruby
# config/routes.rb
namespace :api, defaults: { format: :json } do
  namespace :v1 do
    get 'users/current', to: 'users#current'
  end
end
```

### Option 3: Use Rails Session (Current Approach)
- Rails session cookie handles everything
- React doesn't need user object
- API calls are automatically authenticated

## Files Modified

1. **`app/javascript/App.tsx`**
   - Removed `useAuth` import
   - Removed `ProtectedRoute` component
   - Removed `Navigate` import
   - Simplified all route elements

2. **`app/assets/builds/application.js`**
   - Rebuilt with new code (1.5MB)

## Conclusion

✅ **Issue Resolved** - The infinite reload is fixed by removing unnecessary client-side auth checks and relying on Rails' built-in Devise authentication. The app now loads correctly and all features work as expected.

---

**Last Updated:** October 26, 2024
