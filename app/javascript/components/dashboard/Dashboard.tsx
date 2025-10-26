import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { dashboardApi } from '@/services/api';

const Dashboard: React.FC = () => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => dashboardApi.getDashboard(),
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-900/20 border border-red-500 rounded-lg p-4">
        <p className="text-red-400">Failed to load dashboard data</p>
      </div>
    );
  }

  const dashboard = data?.data;

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold text-white">Dashboard</h1>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Total Portfolio Value */}
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Total Portfolio Value</div>
          <div className="mt-2 text-3xl font-bold text-white">
            KES {dashboard?.total_portfolio_value?.toLocaleString() || '0'}
          </div>
          <div className={`mt-2 text-sm ${
            (dashboard?.total_unrealized_pl || 0) >= 0 ? 'text-green-400' : 'text-red-400'
          }`}>
            {(dashboard?.total_unrealized_pl || 0) >= 0 ? '+' : ''}
            KES {dashboard?.total_unrealized_pl?.toLocaleString() || '0'}
          </div>
        </div>

        {/* Active Orders */}
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Active Orders</div>
          <div className="mt-2 text-3xl font-bold text-white">
            {dashboard?.active_orders_count || 0}
          </div>
          <div className="mt-2 text-sm text-gray-400">
            {dashboard?.pending_orders_count || 0} pending
          </div>
        </div>

        {/* Active Securities */}
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Active Securities</div>
          <div className="mt-2 text-3xl font-bold text-white">
            {dashboard?.active_securities_count || 0}
          </div>
          <div className="mt-2 text-sm text-gray-400">
            Across {dashboard?.exchanges_count || 0} exchanges
          </div>
        </div>

        {/* Watchlists */}
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Watchlists</div>
          <div className="mt-2 text-3xl font-bold text-white">
            {dashboard?.watchlists_count || 0}
          </div>
          <div className="mt-2 text-sm text-gray-400">
            {dashboard?.watchlist_items_count || 0} securities tracked
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Orders */}
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-bold text-white mb-4">Recent Orders</h2>
          {dashboard?.recent_orders && dashboard.recent_orders.length > 0 ? (
            <div className="space-y-3">
              {dashboard.recent_orders.map((order: any) => (
                <div
                  key={order.id}
                  className="flex items-center justify-between p-3 bg-gray-800 rounded-lg"
                >
                  <div>
                    <div className="font-medium text-white">{order.security_symbol}</div>
                    <div className="text-sm text-gray-400">
                      {order.order_type} - {order.quantity} @ KES {order.price}
                    </div>
                  </div>
                  <div className={`px-2 py-1 rounded text-xs font-medium ${
                    order.status === 'filled' ? 'bg-green-900/30 text-green-400' :
                    order.status === 'pending' ? 'bg-yellow-900/30 text-yellow-400' :
                    order.status === 'cancelled' ? 'bg-red-900/30 text-red-400' :
                    'bg-gray-700 text-gray-300'
                  }`}>
                    {order.status}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-400">No recent orders</p>
          )}
        </div>

        {/* Top Movers */}
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-bold text-white mb-4">Top Movers</h2>
          {dashboard?.top_movers && dashboard.top_movers.length > 0 ? (
            <div className="space-y-3">
              {dashboard.top_movers.map((security: any) => (
                <div
                  key={security.id}
                  className="flex items-center justify-between p-3 bg-gray-800 rounded-lg"
                >
                  <div>
                    <div className="font-medium text-white">{security.symbol}</div>
                    <div className="text-sm text-gray-400">{security.name}</div>
                  </div>
                  <div className="text-right">
                    <div className="font-medium text-white">
                      KES {security.latest_price?.toFixed(2)}
                    </div>
                    <div className={`text-sm ${
                      (security.change_percent || 0) >= 0 ? 'text-green-400' : 'text-red-400'
                    }`}>
                      {(security.change_percent || 0) >= 0 ? '+' : ''}
                      {security.change_percent?.toFixed(2)}%
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-400">No market data available</p>
          )}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
