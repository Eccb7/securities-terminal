import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams, Link } from 'react-router-dom';
import { newsApi } from '@/services/api';

const NewsArticle: React.FC = () => {
  const { id } = useParams<{ id: string }>();

  const { data, isLoading, error } = useQuery({
    queryKey: ['news', id],
    queryFn: () => newsApi.getById(parseInt(id!)),
    enabled: !!id,
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="space-y-4">
        <Link
          to="/news"
          className="inline-flex items-center text-blue-400 hover:text-blue-300"
        >
          ← Back to News
        </Link>
        <div className="bg-red-900/20 border border-red-500 rounded-lg p-4">
          <p className="text-red-400">Failed to load article</p>
        </div>
      </div>
    );
  }

  const article = data;

  return (
    <div className="space-y-6">
      {/* Back Button */}
      <Link
        to="/news"
        className="inline-flex items-center text-blue-400 hover:text-blue-300"
      >
        ← Back to News
      </Link>

      {/* Article */}
      <article className="bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
        {/* Header */}
        <div className="p-6 border-b border-gray-800">
          <div className="space-y-3">
            <h1 className="text-3xl font-bold text-white">{article.title}</h1>
            <div className="flex items-center gap-4 text-sm text-gray-400">
              <span className="px-2 py-1 bg-gray-800 rounded text-xs font-medium capitalize">
                {article.category}
              </span>
              <span>{new Date(article.published_at).toLocaleString()}</span>
              {article.exchange && (
                <span className="text-blue-400">{article.exchange.name}</span>
              )}
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {/* Summary */}
          {article.summary && (
            <div className="mb-6 p-4 bg-gray-800/50 rounded-lg">
              <p className="text-lg text-gray-300">{article.summary}</p>
            </div>
          )}

          {/* Main Content */}
          {article.content && (
            <div className="prose prose-invert max-w-none">
              <div className="text-gray-300 whitespace-pre-wrap leading-relaxed">
                {article.content}
              </div>
            </div>
          )}

          {/* Source Link */}
          {article.url && (
            <div className="mt-6 pt-6 border-t border-gray-800">
              <a
                href={article.url}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center text-blue-400 hover:text-blue-300"
              >
                Read full article on source website →
              </a>
            </div>
          )}
        </div>

        {/* Related Securities */}
        {article.securities && article.securities.length > 0 && (
          <div className="p-6 border-t border-gray-800 bg-gray-800/30">
            <h3 className="text-lg font-semibold text-white mb-4">
              Related Securities
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {article.securities.map((security) => (
                <Link
                  key={security.id}
                  to={`/securities/${security.id}`}
                  className="block bg-gray-900 border border-gray-700 rounded-lg p-4 hover:border-blue-500 transition-colors"
                >
                  <div className="space-y-2">
                    <div className="flex items-start justify-between">
                      <div>
                        <div className="font-semibold text-white">
                          {security.symbol}
                        </div>
                        <div className="text-sm text-gray-400">
                          {security.name}
                        </div>
                      </div>
                      {security.latest_quote && (
                        <div className="text-right">
                          <div className="font-semibold text-white">
                            ${security.latest_quote.price.toFixed(2)}
                          </div>
                          <div
                            className={`text-sm ${
                              security.latest_quote.change >= 0
                                ? 'text-green-400'
                                : 'text-red-400'
                            }`}
                          >
                            {security.latest_quote.change >= 0 ? '+' : ''}
                            {security.latest_quote.change.toFixed(2)} (
                            {security.latest_quote.change_percent.toFixed(2)}%)
                          </div>
                        </div>
                      )}
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        )}
      </article>
    </div>
  );
};

export default NewsArticle;
