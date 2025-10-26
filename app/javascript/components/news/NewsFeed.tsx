import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { newsApi } from '@/services/api';
import { NewsItem } from '@/types';

const NewsFeed: React.FC = () => {
  const [categoryFilter, setCategoryFilter] = useState('');

  const { data, isLoading, error } = useQuery({
    queryKey: ['news', categoryFilter],
    queryFn: () => newsApi.getAll({ category: categoryFilter || undefined }),
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
        <p className="text-red-400">Failed to load news</p>
      </div>
    );
  }

  const newsItems = data?.data || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-white">News Feed</h1>
      </div>

      {/* Filters */}
      <div className="bg-gray-900 border border-gray-800 rounded-lg p-4">
        <div className="flex gap-4">
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-400 mb-2">
              Category
            </label>
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">All Categories</option>
              <option value="market">Market</option>
              <option value="company">Company</option>
              <option value="economy">Economy</option>
              <option value="earnings">Earnings</option>
              <option value="regulation">Regulation</option>
            </select>
          </div>
        </div>
      </div>

      {/* News Grid */}
      {newsItems.length === 0 ? (
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-8 text-center text-gray-400">
          No news found
        </div>
      ) : (
        <div className="space-y-4">
          {newsItems.map((item: NewsItem) => (
            <Link
              key={item.id}
              to={`/news/${item.id}`}
              className="block bg-gray-900 border border-gray-800 rounded-lg p-6 hover:border-blue-500 transition-colors"
            >
              <div className="space-y-3">
                {/* Header */}
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <h3 className="text-xl font-bold text-white hover:text-blue-400">
                      {item.title}
                    </h3>
                    <div className="flex items-center gap-3 mt-2 text-sm text-gray-400">
                      <span className="px-2 py-1 bg-gray-800 rounded text-xs font-medium capitalize">
                        {item.category}
                      </span>
                      <span>{new Date(item.published_at).toLocaleString()}</span>
                      {item.exchange && (
                        <span className="text-blue-400">{item.exchange.name}</span>
                      )}
                    </div>
                  </div>
                </div>

                {/* Summary */}
                {item.summary && (
                  <p className="text-gray-400 line-clamp-2">{item.summary}</p>
                )}

                {/* Related Securities */}
                {item.securities && item.securities.length > 0 && (
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="text-sm text-gray-400">Related:</span>
                    {item.securities.map((security) => (
                      <span
                        key={security.id}
                        className="px-2 py-1 bg-gray-800 rounded text-sm text-blue-400"
                      >
                        {security.symbol}
                      </span>
                    ))}
                  </div>
                )}
              </div>
            </Link>
          ))}
        </div>
      )}

      {/* Pagination */}
      {data?.meta && (
        <div className="flex items-center justify-between text-sm text-gray-400">
          <div>
            Showing {newsItems.length} of {data.meta.total_count} articles
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

export default NewsFeed;
