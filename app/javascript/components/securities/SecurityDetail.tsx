import React, { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { securitiesApi } from '@/services/api';
import { Security } from '@/types';
import { LoadingSpinner } from '@/components/common/LoadingSpinner';
import { actionCableService } from '@/services/actionCable';

const SecurityDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [liveQuote, setLiveQuote] = useState<any>(null);

  // Fetch security details
  const { data, isLoading, error } = useQuery({
    queryKey: ['security', id],
    queryFn: () => securitiesApi.getById(Number(id)),
    enabled: !!id,
  });

  const security = data?.data;

  // Subscribe to real-time quotes for this security
  useEffect(() => {
    if (security?.symbol) {
      actionCableService.subscribeToMarket([security.symbol], (quoteUpdate) => {
        if (quoteUpdate.symbol === security.symbol) {
          setLiveQuote(quoteUpdate);
        }
      });
    }

    return () => {
      actionCableService.unsubscribeAll();
    };
  }, [security?.symbol]);

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (error || !security) {
    return (
      <div className="space-y-4">
        <div className="bg-red-900/20 border border-red-500 rounded-lg p-4">
          <p className="text-red-400">Failed to load security details</p>
        </div>
        <button
          onClick={() => navigate('/securities')}
          className="px-4 py-2 bg-gray-800 text-white rounded hover:bg-gray-700"
        >
          Back to Securities
        </button>
      </div>
    );
  }

  // Use live quote if available, otherwise use latest quote from DB
  const quote = liveQuote || security.latest_quote;
  const changePercent = quote?.change_percent || 0;
  const changeColor = changePercent >= 0 ? 'text-green-400' : 'text-red-400';

  return (
    <div className="space-y-6">
      {/* Header with back button */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigate('/securities')}
            className="p-2 hover:bg-gray-800 rounded transition-colors"
            title="Back to Securities"
          >
            <svg className="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <div>
            <h1 className="text-3xl font-bold text-white">{security.symbol}</h1>
            <p className="text-gray-400">{security.name}</p>
          </div>
        </div>
        
        <div className="flex items-center space-x-2">
          {liveQuote && (
            <div className="flex items-center space-x-2 px-3 py-1 bg-green-900/20 border border-green-500/30 rounded">
              <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse"></div>
              <span className="text-green-400 text-sm font-medium">Live</span>
            </div>
          )}
          <span className={`px-3 py-1 rounded text-sm font-medium ${
            security.status === 'active' 
              ? 'bg-green-900/30 text-green-400' 
              : 'bg-gray-700 text-gray-400'
          }`}>
            {security.status}
          </span>
        </div>
      </div>

      {/* Price Overview */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Last Price</div>
          <div className="mt-2 text-3xl font-bold text-white">
            KES {quote?.last_price?.toFixed(2) || '0.00'}
          </div>
          <div className={`mt-2 text-sm font-medium ${changeColor}`}>
            {changePercent >= 0 ? '+' : ''}
            {changePercent.toFixed(2)}% today
          </div>
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Day Range</div>
          <div className="mt-2 text-xl font-bold text-white">
            {quote?.low_price?.toFixed(2) || '0.00'} - {quote?.high_price?.toFixed(2) || '0.00'}
          </div>
          <div className="mt-2 text-sm text-gray-400">
            Open: KES {quote?.open_price?.toFixed(2) || '0.00'}
          </div>
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Volume</div>
          <div className="mt-2 text-xl font-bold text-white">
            {quote?.volume?.toLocaleString() || '0'}
          </div>
          <div className="mt-2 text-sm text-gray-400">
            Avg: {quote?.average_price?.toFixed(2) || '0.00'}
          </div>
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Bid/Ask</div>
          <div className="mt-2 text-xl font-bold text-white">
            {quote?.bid_price?.toFixed(2) || '-'} / {quote?.ask_price?.toFixed(2) || '-'}
          </div>
          <div className="mt-2 text-sm text-gray-400">
            Spread: {((quote?.ask_price - quote?.bid_price) || 0).toFixed(2)}
          </div>
        </div>
      </div>

      {/* Security Information */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Basic Info */}
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-bold text-white mb-4">Security Information</h2>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-400">ISIN</span>
              <span className="text-white font-medium">{security.isin || 'N/A'}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Exchange</span>
              <span className="text-white font-medium">
                {security.exchange?.name || 'N/A'} ({security.exchange?.code})
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Type</span>
              <span className="text-white font-medium capitalize">{security.security_type}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Sector</span>
              <span className="text-white font-medium">{security.sector || 'N/A'}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Currency</span>
              <span className="text-white font-medium">{security.currency || 'KES'}</span>
            </div>
          </div>
        </div>

        {/* Trading Info */}
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-bold text-white mb-4">Trading Information</h2>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-400">52 Week High</span>
              <span className="text-white font-medium">
                KES {quote?.week_52_high?.toFixed(2) || 'N/A'}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">52 Week Low</span>
              <span className="text-white font-medium">
                KES {quote?.week_52_low?.toFixed(2) || 'N/A'}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Market Cap</span>
              <span className="text-white font-medium">
                {security.market_cap 
                  ? `KES ${(security.market_cap / 1000000).toFixed(2)}M` 
                  : 'N/A'}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Shares Outstanding</span>
              <span className="text-white font-medium">
                {security.shares_outstanding?.toLocaleString() || 'N/A'}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-400">Last Updated</span>
              <span className="text-white font-medium">
                {quote?.timestamp 
                  ? new Date(quote.timestamp).toLocaleString() 
                  : 'N/A'}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Description */}
      {security.description && (
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-bold text-white mb-4">About</h2>
          <p className="text-gray-300 leading-relaxed">{security.description}</p>
        </div>
      )}

      {/* Action Buttons */}
      <div className="flex items-center space-x-4">
        <Link
          to={`/orders/new?security_id=${security.id}`}
          className="px-6 py-3 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition-colors"
        >
          Place Order
        </Link>
        <button
          onClick={() => {
            // TODO: Implement add to watchlist functionality
            alert('Add to watchlist functionality coming soon!');
          }}
          className="px-6 py-3 bg-gray-800 text-white rounded-lg font-medium hover:bg-gray-700 transition-colors"
        >
          Add to Watchlist
        </button>
        <button
          onClick={() => {
            // TODO: Implement chart view
            alert('Chart view coming soon!');
          }}
          className="px-6 py-3 bg-gray-800 text-white rounded-lg font-medium hover:bg-gray-700 transition-colors"
        >
          View Chart
        </button>
      </div>

      {/* Quote Update Timestamp */}
      {liveQuote && (
        <div className="text-center text-sm text-gray-500">
          Last updated: {new Date(liveQuote.timestamp).toLocaleTimeString()}
        </div>
      )}
    </div>
  );
};

export default SecurityDetail;
