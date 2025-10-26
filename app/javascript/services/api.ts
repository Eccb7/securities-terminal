import { apiClient } from './apiClient';
import type {
  User,
  Security,
  Order,
  Portfolio,
  Watchlist,
  NewsItem,
  AlertRule,
  PaginatedResponse,
  ApiResponse,
} from '@/types';

// Dashboard API
export const dashboardApi = {
  getDashboard: () => apiClient.get<{
    portfolios: Portfolio[];
    recent_orders: Order[];
    recent_news: NewsItem[];
    alert_events: any[];
    market_overview: Security[];
  }>('/dashboard'),
};

// Securities API
export const securitiesApi = {
  getAll: (params?: {
    page?: number;
    per_page?: number;
    instrument_type?: string;
    exchange_id?: number;
    q?: string;
  }) => apiClient.get<PaginatedResponse<Security>>('/securities', { params }),
  
  getSecurities: (params?: {
    page?: number;
    instrument_type?: string;
    exchange_id?: number;
    q?: string;
  }) => apiClient.get<PaginatedResponse<Security>>('/securities', { params }),
  
  getById: (id: number) => apiClient.get<ApiResponse<Security>>(`/securities/${id}`),
  
  getSecurity: (id: number) => apiClient.get<ApiResponse<Security>>(`/securities/${id}`),
  
  getQuote: (id: number) => apiClient.get<any>(`/securities/${id}/quote`),
  
  getChartData: (id: number, period?: string) => 
    apiClient.get<any>(`/securities/${id}/chart_data`, { params: { period } }),
};

// Orders API
export const ordersApi = {
  getAll: (params?: { page?: number; status?: string }) =>
    apiClient.get<PaginatedResponse<Order>>('/orders', { params }),
    
  getOrders: (params?: { page?: number; status?: string }) =>
    apiClient.get<PaginatedResponse<Order>>('/orders', { params }),
  
  getById: (id: number) => apiClient.get<ApiResponse<Order>>(`/orders/${id}`),
  
  getOrder: (id: number) => apiClient.get<ApiResponse<Order>>(`/orders/${id}`),
  
  create: (data: Partial<Order>) =>
    apiClient.post<ApiResponse<Order>>('/orders', { order: data }),
    
  createOrder: (data: Partial<Order>) =>
    apiClient.post<ApiResponse<Order>>('/orders', { order: data }),
  
  cancel: (id: number) =>
    apiClient.post<ApiResponse<Order>>(`/orders/${id}/cancel`),
    
  cancelOrder: (id: number) =>
    apiClient.post<ApiResponse<Order>>(`/orders/${id}/cancel`),
};

// Portfolios API
export const portfoliosApi = {
  getAll: () => apiClient.get<ApiResponse<Portfolio[]>>('/portfolios'),
  
  getPortfolios: () => apiClient.get<ApiResponse<Portfolio[]>>('/portfolios'),
  
  getById: (id: number) => apiClient.get<ApiResponse<Portfolio>>(`/portfolios/${id}`),
  
  getPortfolio: (id: number) => apiClient.get<ApiResponse<Portfolio>>(`/portfolios/${id}`),
  
  create: (data: Partial<Portfolio>) =>
    apiClient.post<ApiResponse<Portfolio>>('/portfolios', { portfolio: data }),
    
  createPortfolio: (data: Partial<Portfolio>) =>
    apiClient.post<ApiResponse<Portfolio>>('/portfolios', { portfolio: data }),
  
  update: (id: number, data: Partial<Portfolio>) =>
    apiClient.put<ApiResponse<Portfolio>>(`/portfolios/${id}`, { portfolio: data }),
    
  updatePortfolio: (id: number, data: Partial<Portfolio>) =>
    apiClient.put<ApiResponse<Portfolio>>(`/portfolios/${id}`, { portfolio: data }),
  
  delete: (id: number) =>
    apiClient.delete<ApiResponse<void>>(`/portfolios/${id}`),
    
  deletePortfolio: (id: number) =>
    apiClient.delete<ApiResponse<void>>(`/portfolios/${id}`),
};

// Watchlists API
export const watchlistsApi = {
  getAll: () => apiClient.get<ApiResponse<Watchlist[]>>('/watchlists'),
  
  getWatchlists: () => apiClient.get<ApiResponse<Watchlist[]>>('/watchlists'),
  
  getById: (id: number) => apiClient.get<ApiResponse<Watchlist>>(`/watchlists/${id}`),
  
  getWatchlist: (id: number) => apiClient.get<ApiResponse<Watchlist>>(`/watchlists/${id}`),
  
  create: (data: Partial<Watchlist>) =>
    apiClient.post<ApiResponse<Watchlist>>('/watchlists', { watchlist: data }),
    
  createWatchlist: (data: Partial<Watchlist>) =>
    apiClient.post<ApiResponse<Watchlist>>('/watchlists', { watchlist: data }),
  
  update: (id: number, data: Partial<Watchlist>) =>
    apiClient.put<ApiResponse<Watchlist>>(`/watchlists/${id}`, { watchlist: data }),
    
  updateWatchlist: (id: number, data: Partial<Watchlist>) =>
    apiClient.put<ApiResponse<Watchlist>>(`/watchlists/${id}`, { watchlist: data }),
  
  delete: (id: number) =>
    apiClient.delete<ApiResponse<void>>(`/watchlists/${id}`),
    
  deleteWatchlist: (id: number) =>
    apiClient.delete<ApiResponse<void>>(`/watchlists/${id}`),
  
  addSecurity: (id: number, securityId: number) =>
    apiClient.post<ApiResponse<void>>(`/watchlists/${id}/add_security`, { security_id: securityId }),
  
  removeSecurity: (id: number, securityId: number) =>
    apiClient.delete<ApiResponse<void>>(`/watchlists/${id}/remove_security/${securityId}`),
};

// News API
export const newsApi = {
  getAll: (params?: {
    page?: number;
    security_id?: number;
    category?: string;
    query?: string;
  }) => apiClient.get<PaginatedResponse<NewsItem>>('/news_items', { params }),
    
  getNews: (params?: {
    page?: number;
    security_id?: number;
    category?: string;
    query?: string;
  }) => apiClient.get<PaginatedResponse<NewsItem>>('/news_items', { params }),
  
  getById: (id: number) => apiClient.get<NewsItem>(`/news_items/${id}`),
  
  getNewsItem: (id: number) => apiClient.get<ApiResponse<NewsItem>>(`/news_items/${id}`),
};

// Alert Rules API
export const alertRulesApi = {
  getAll: () => apiClient.get<ApiResponse<AlertRule[]>>('/alert_rules'),
  
  getAlerts: () => apiClient.get<ApiResponse<AlertRule[]>>('/alert_rules'),
  
  getById: (id: number) => apiClient.get<ApiResponse<AlertRule>>(`/alert_rules/${id}`),
  
  getAlert: (id: number) => apiClient.get<ApiResponse<AlertRule>>(`/alert_rules/${id}`),
  
  create: (data: Partial<AlertRule>) =>
    apiClient.post<ApiResponse<AlertRule>>('/alert_rules', { alert_rule: data }),
    
  createAlert: (data: Partial<AlertRule>) =>
    apiClient.post<ApiResponse<AlertRule>>('/alert_rules', { alert_rule: data }),
  
  update: (id: number, data: Partial<AlertRule>) =>
    apiClient.put<ApiResponse<AlertRule>>(`/alert_rules/${id}`, { alert_rule: data }),
    
  updateAlert: (id: number, data: Partial<AlertRule>) =>
    apiClient.put<ApiResponse<AlertRule>>(`/alert_rules/${id}`, { alert_rule: data }),
  
  delete: (id: number) =>
    apiClient.delete<ApiResponse<void>>(`/alert_rules/${id}`),
    
  deleteAlert: (id: number) =>
    apiClient.delete<ApiResponse<void>>(`/alert_rules/${id}`),
};

// Legacy alias for backwards compatibility
export const alertsApi = alertRulesApi;

// User/Auth API
export const authApi = {
  getCurrentUser: () => apiClient.get<ApiResponse<User>>('/current_user'),
  
  signOut: () => apiClient.delete<void>('/users/sign_out'),
};
