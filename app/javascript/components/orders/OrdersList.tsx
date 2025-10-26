import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { ordersApi } from '@/services/api';
import { Order } from '@/types';

const OrdersList: React.FC = () => {
  const [statusFilter, setStatusFilter] = useState<string>('');
  const queryClient = useQueryClient();

  const { data, isLoading, error } = useQuery({
    queryKey: ['orders', statusFilter],
    queryFn: () => ordersApi.getAll({ status: statusFilter || undefined }),
  });

  const cancelMutation = useMutation({
    mutationFn: (orderId: number) => ordersApi.cancel(orderId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
    },
  });

  const handleCancel = async (orderId: number) => {
    if (confirm('Are you sure you want to cancel this order?')) {
      try {
        await cancelMutation.mutateAsync(orderId);
        alert('Order cancelled successfully');
      } catch (error) {
        alert('Failed to cancel order');
      }
    }
  };

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
        <p className="text-red-400">Failed to load orders</p>
      </div>
    );
  }

  const orders = data?.data || [];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'filled':
        return 'bg-green-900/30 text-green-400';
      case 'pending':
        return 'bg-yellow-900/30 text-yellow-400';
      case 'partially_filled':
        return 'bg-blue-900/30 text-blue-400';
      case 'cancelled':
        return 'bg-red-900/30 text-red-400';
      case 'rejected':
        return 'bg-red-900/30 text-red-400';
      default:
        return 'bg-gray-700 text-gray-300';
    }
  };

  const getSideColor = (side: string) => {
    return side === 'buy' ? 'text-green-400' : 'text-red-400';
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-white">Orders</h1>
        <Link
          to="/orders/new"
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-md text-white font-medium transition-colors"
        >
          New Order
        </Link>
      </div>

      {/* Filters */}
      <div className="bg-gray-900 border border-gray-800 rounded-lg p-4">
        <div className="flex gap-4">
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-400 mb-2">
              Status
            </label>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="filled">Filled</option>
              <option value="partially_filled">Partially Filled</option>
              <option value="cancelled">Cancelled</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
        </div>
      </div>

      {/* Orders Table */}
      <div className="bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
        {orders.length === 0 ? (
          <div className="p-8 text-center text-gray-400">
            No orders found
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-800">
                  <th className="px-4 py-3 text-left text-sm font-medium text-gray-400">
                    Security
                  </th>
                  <th className="px-4 py-3 text-left text-sm font-medium text-gray-400">
                    Type
                  </th>
                  <th className="px-4 py-3 text-left text-sm font-medium text-gray-400">
                    Side
                  </th>
                  <th className="px-4 py-3 text-right text-sm font-medium text-gray-400">
                    Quantity
                  </th>
                  <th className="px-4 py-3 text-right text-sm font-medium text-gray-400">
                    Price
                  </th>
                  <th className="px-4 py-3 text-right text-sm font-medium text-gray-400">
                    Total
                  </th>
                  <th className="px-4 py-3 text-center text-sm font-medium text-gray-400">
                    Status
                  </th>
                  <th className="px-4 py-3 text-right text-sm font-medium text-gray-400">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody>
                {orders.map((order: Order) => (
                  <tr key={order.id} className="border-b border-gray-800 hover:bg-gray-800/50">
                    <td className="px-4 py-3">
                      <div>
                        <div className="font-medium text-white">
                          {order.security?.symbol}
                        </div>
                        <div className="text-sm text-gray-400">
                          {order.security?.name}
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-white capitalize">
                      {order.order_type.replace('_', ' ')}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`font-medium capitalize ${getSideColor(order.side)}`}>
                        {order.side}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right text-white">
                      {order.quantity?.toLocaleString()}
                    </td>
                    <td className="px-4 py-3 text-right text-white">
                      KES {order.price?.toFixed(2)}
                    </td>
                    <td className="px-4 py-3 text-right text-white font-medium">
                      KES {order.total_cost?.toLocaleString()}
                    </td>
                    <td className="px-4 py-3 text-center">
                      <span className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(order.status)}`}>
                        {order.status.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="flex gap-2 justify-end">
                        <Link
                          to={`/orders/${order.id}`}
                          className="text-blue-400 hover:text-blue-300 text-sm"
                        >
                          View
                        </Link>
                        {order.status === 'pending' && (
                          <button
                            onClick={() => handleCancel(order.id)}
                            disabled={cancelMutation.isPending}
                            className="text-red-400 hover:text-red-300 text-sm disabled:opacity-50"
                          >
                            Cancel
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Pagination */}
      {data?.meta && (
        <div className="flex items-center justify-between text-sm text-gray-400">
          <div>
            Showing {orders.length} of {data.meta.total_count} orders
          </div>
          <div className="flex gap-2">
            {data.meta.current_page > 1 && (
              <button className="px-3 py-1 bg-gray-800 hover:bg-gray-700 rounded">
                Previous
              </button>
            )}
            {data.meta.current_page < data.meta.total_pages && (
              <button className="px-3 py-1 bg-gray-800 hover:bg-gray-700 rounded">
                Next
              </button>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default OrdersList;
