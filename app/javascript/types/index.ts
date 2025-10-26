// User types
export interface User {
  id: number;
  email: string;
  name: string;
  role: 'viewer' | 'analyst' | 'trader' | 'compliance_officer' | 'admin' | 'super_admin';
  trading_restricted: boolean;
  two_fa_enabled: boolean;
  organization_id: number;
  created_at: string;
  updated_at: string;
}

// Security types
export interface Security {
  id: number;
  ticker: string;
  name: string;
  exchange_id: number;
  instrument_type: 'equity' | 'bond' | 'etf';
  currency: string;
  status: 'active' | 'suspended' | 'delisted';
  isin?: string;
  lot_size: number;
  created_at: string;
  updated_at: string;
  exchange?: Exchange;
  latest_quote?: MarketQuote;
}

// Exchange types
export interface Exchange {
  id: number;
  code: string;
  name: string;
  country: string;
  timezone: string;
  currency: string;
  status: string;
  market_open: string;
  market_close: string;
}

// Market Quote types
export interface MarketQuote {
  id: number;
  security_id: number;
  bid: number;
  ask: number;
  last_price: number;
  volume: number;
  high?: number;
  low?: number;
  open?: number;
  close?: number;
  timestamp: string;
  price_change?: number;
  price_change_percentage?: number;
}

// Order types
export interface Order {
  id: number;
  user_id: number;
  security_id: number;
  portfolio_id: number;
  side: 'buy' | 'sell';
  order_type: 'market' | 'limit' | 'stop' | 'stop_limit';
  quantity: number;
  price?: number;
  stop_price?: number;
  filled_quantity: number;
  status: 'pending' | 'open' | 'partially_filled' | 'filled' | 'cancelled' | 'rejected' | 'expired';
  created_at: string;
  updated_at: string;
  security?: Security;
}

// Portfolio types
export interface Portfolio {
  id: number;
  user_id: number;
  name: string;
  cash_balance: number;
  portfolio_type: string;
  total_value?: number;
  profit_loss?: number;
  profit_loss_percentage?: number;
  created_at: string;
  updated_at: string;
  positions?: Position[];
}

// Position types
export interface Position {
  id: number;
  portfolio_id: number;
  security_id: number;
  quantity: number;
  average_cost: number;
  current_price?: number;
  market_value?: number;
  profit_loss?: number;
  profit_loss_percentage?: number;
  created_at: string;
  updated_at: string;
  security?: Security;
}

// Watchlist types
export interface Watchlist {
  id: number;
  user_id: number;
  name: string;
  created_at: string;
  updated_at: string;
  watchlist_items?: WatchlistItem[];
  securities?: Security[];
}

export interface WatchlistItem {
  id: number;
  watchlist_id: number;
  security_id: number;
  created_at: string;
  updated_at: string;
  security?: Security;
}

// News types
export interface NewsItem {
  id: number;
  title: string;
  content: string;
  source?: string;
  url?: string;
  category?: string;
  security_id?: number;
  published_at: string;
  created_at: string;
  updated_at: string;
  security?: Security;
}

// Alert types
export interface AlertRule {
  id: number;
  user_id: number;
  security_id: number;
  condition_type: 'price' | 'volume' | 'percent_change';
  comparison_operator: 'greater_than' | 'less_than' | 'equals';
  threshold_value: number;
  notification_method: 'email' | 'in_app' | 'both';
  status: 'active' | 'inactive' | 'triggered';
  created_at: string;
  updated_at: string;
  security?: Security;
  alert_events?: AlertEvent[];
}

export interface AlertEvent {
  id: number;
  alert_rule_id: number;
  triggered_at: string;
  actual_value: number;
  status: 'pending' | 'resolved';
  message?: string;
  resolved_at?: string;
  created_at: string;
  updated_at: string;
}

// API Response types
export interface ApiResponse<T> {
  data: T;
  message?: string;
  errors?: string[];
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    current_page: number;
    total_pages: number;
    total_count: number;
    per_page: number;
  };
}

// WebSocket message types
export interface WebSocketMessage {
  type: string;
  [key: string]: any;
}

export interface QuoteUpdate extends WebSocketMessage {
  type: 'quote';
  ticker: string;
  bid: number;
  ask: number;
  last_price: number;
  volume: number;
  timestamp: number;
}

export interface OrderUpdate extends WebSocketMessage {
  type: 'order';
  order_id: number;
  status: string;
  filled_quantity: number;
}

export interface AlertNotification extends WebSocketMessage {
  type: 'alert';
  alert_id: number;
  message: string;
  security: string;
}
