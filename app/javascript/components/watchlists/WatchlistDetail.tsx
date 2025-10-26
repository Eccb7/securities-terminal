import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { watchlistsApi, securitiesApi } from '@/services/api';
import { WatchlistItem } from '@/types';

const WatchlistDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [showAddForm, setShowAddForm] = useState(false);
  const [selectedSecurityId, setSelectedSecurityId] = useState('');

  const { data, isLoading, error } = useQuery({
    queryKey: ['watchlist', id],
    queryFn: () => watchlistsApi.getById(parseInt(id!)),
    enabled: !!id,
    refetchInterval: 5000, // Refresh every 5 seconds for real-time prices
  });

  const { data: securitiesData } = useQuery({
    queryKey: ['securities'],
    queryFn: () => securitiesApi.getAll({}),
    enabled: showAddForm,
  });

  const addSecurityMutation = useMutation({
    mutationFn: ({ watchlistId, securityId }: { watchlistId: number; securityId: number }) =>
      watchlistsApi.addSecurity(watchlistId, securityId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist', id] });
      setShowAddForm(false);
      setSelectedSecurityId('');
    },
  });

  const removeSecurityMutation = useMutation({
    mutationFn: ({ watchlistId, itemId }: { watchlistId: number; itemId: number }) =>
      watchlistsApi.removeSecurity(watchlistId, itemId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlist', id] });
    },
  });

  const handleAddSecurity = async (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedSecurityId && id) {
      await addSecurityMutation.mutateAsync({
        watchlistId: parseInt(id),
        securityId: parseInt(selectedSecurityId),
      });
    }
  };

  const handleRemoveSecurity = async (itemId: number) => {
    if (confirm('Remove this security from watchlist?') && id) {
      await removeSecurityMutation.mutateAsync({
        watchlistId: parseInt(id),
        itemId,
      });
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
        <p className="text-red-400">Failed to load watchlist</p>
      </div>
    );
  }

  const watchlist = data?.data;
  const items = watchlist?.watchlist_items || [];
  const securities = securitiesData?.data || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <button
            onClick={() => navigate('/watchlists')}
            className="text-gray-400 hover:text-white mb-2"
          >
            ← Back to Watchlists
          </button>
          <h1 className="text-3xl font-bold text-white">{watchlist?.name}</h1>
          {watchlist?.description && (
            <p className="text-gray-400 mt-1">{watchlist.description}</p>
          )}
        </div>
        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-md text-white font-medium transition-colors"
        >
          {showAddForm ? 'Cancel' : 'Add Security'}
        </button>
      </div>

      {/* Add Security Form */}
      {showAddForm && (
        <form onSubmit={handleAddSecurity} className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="flex gap-4">
            <div className="flex-1">
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Select Security
              </label>
              <select
                value={selectedSecurityId}
                onChange={(e) => setSelectedSecurityId(e.target.value)}
                required
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Choose a security...</option>
                {securities.map((security: any) => (
                  <option key={security.id} value={security.id}>
                    {security.symbol} - {security.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex items-end">
              <button
                type="submit"
                disabled={addSecurityMutation.isPending || !selectedSecurityId}
                className="px-6 py-2 bg-blue-600 hover:bg-blue-700 rounded-md text-white font-medium transition-colors disabled:opacity-50"
              >
                {addSecurityMutation.isPending ? 'Adding...' : 'Add'}
              </button>
            </div>
          </div>
        </form>
      )}

      {/* Securities Table */}
      <div className="bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
        {items.length === 0 ? (
          <div className="p-8 text-center text-gray-400">
            No securities in this watchlist yet. Add securities to start tracking their prices!
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-800">
                  <th className="px-6 py-3 text-left text-sm font-medium text-gray-400">
                    Security
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Last Price
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Change
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Change %
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Volume
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody>
                {items.map((item: WatchlistItem) => (
                  <tr key={item.id} className="border-b border-gray-800 hover:bg-gray-800/50">
                    <td className="px-6 py-4">
                      <Link
                        to={`/securities/${item.security.id}`}
                        className="block hover:text-blue-400"
                      >
                        <div className="font-medium text-white">
                          {item.security.symbol}
                        </div>
                        <div className="text-sm text-gray-400">
                          {item.security.name}
                        </div>
                      </Link>
                    </td>
                    <td className="px-6 py-4 text-right text-white font-medium">
                      KES {item.security.latest_quote?.last_price?.toFixed(2) || '-'}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className={
                        (item.security.latest_quote?.change || 0) >= 0
                          ? 'text-green-400'
                          : 'text-red-400'
                      }>
                        {(item.security.latest_quote?.change || 0) >= 0 ? '+' : ''}
                        {item.security.latest_quote?.change?.toFixed(2) || '-'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className={
                        (item.security.latest_quote?.change_percent || 0) >= 0
                          ? 'text-green-400'
                          : 'text-red-400'
                      }>
                        {(item.security.latest_quote?.change_percent || 0) >= 0 ? '+' : ''}
                        {item.security.latest_quote?.change_percent?.toFixed(2)}%
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right text-gray-400">
                      {item.security.latest_quote?.volume?.toLocaleString() || '-'}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => handleRemoveSecurity(item.id)}
                        disabled={removeSecurityMutation.isPending}
                        className="text-red-400 hover:text-red-300 text-sm disabled:opacity-50"
                      >
                        Remove
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default WatchlistDetail;
