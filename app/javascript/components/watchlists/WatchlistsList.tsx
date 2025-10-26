import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { watchlistsApi } from '@/services/api';
import { Watchlist } from '@/types';

const WatchlistsList: React.FC = () => {
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [formData, setFormData] = useState({ name: '', description: '' });
  const queryClient = useQueryClient();

  const { data, isLoading, error } = useQuery({
    queryKey: ['watchlists'],
    queryFn: () => watchlistsApi.getAll(),
  });

  const createMutation = useMutation({
    mutationFn: (data: any) => watchlistsApi.create({ watchlist: data }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['watchlists'] });
      setShowCreateForm(false);
      setFormData({ name: '', description: '' });
    },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await createMutation.mutateAsync(formData);
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
        <p className="text-red-400">Failed to load watchlists</p>
      </div>
    );
  }

  const watchlists = data?.data || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-white">Watchlists</h1>
        <button
          onClick={() => setShowCreateForm(!showCreateForm)}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-md text-white font-medium transition-colors"
        >
          {showCreateForm ? 'Cancel' : 'New Watchlist'}
        </button>
      </div>

      {/* Create Form */}
      {showCreateForm && (
        <form onSubmit={handleSubmit} className="bg-gray-900 border border-gray-800 rounded-lg p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">
              Watchlist Name *
            </label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="My Watchlist"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">
              Description
            </label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              rows={3}
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Optional description..."
            />
          </div>
          <button
            type="submit"
            disabled={createMutation.isPending}
            className="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-md text-white font-medium transition-colors disabled:opacity-50"
          >
            {createMutation.isPending ? 'Creating...' : 'Create Watchlist'}
          </button>
        </form>
      )}

      {/* Watchlists Grid */}
      {watchlists.length === 0 ? (
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-8 text-center">
          <p className="text-gray-400">No watchlists yet. Create your first watchlist to track securities!</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {watchlists.map((watchlist: Watchlist) => (
            <Link
              key={watchlist.id}
              to={`/watchlists/${watchlist.id}`}
              className="bg-gray-900 border border-gray-800 rounded-lg p-6 hover:border-blue-500 transition-colors"
            >
              <div className="space-y-4">
                <div>
                  <h3 className="text-xl font-bold text-white">{watchlist.name}</h3>
                  {watchlist.description && (
                    <p className="text-sm text-gray-400 mt-1">{watchlist.description}</p>
                  )}
                </div>

                <div className="flex items-center justify-between">
                  <span className="text-gray-400 text-sm">Securities</span>
                  <span className="text-2xl font-bold text-white">
                    {watchlist.securities_count || 0}
                  </span>
                </div>

                <div className="pt-4 border-t border-gray-800">
                  <div className="text-sm text-gray-400">
                    Created {new Date(watchlist.created_at).toLocaleDateString()}
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
};

export default WatchlistsList;
