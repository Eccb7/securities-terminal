import React, { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { securitiesApi } from '@/services/api';
import { Security } from '@/types';
import { LoadingSpinner } from '@/components/common/LoadingSpinner';
import { actionCableService } from '@/services/actionCable';

const SecuritiesList: React.FC = () => {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [exchange, setExchange] = useState('');
  const [securityType, setSecurityType] = useState('');
  const [quotes, setQuotes] = useState<Record<string, any>>({});

  // Fetch securities with filters
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['securities', page, search, exchange, securityType],
    queryFn: () => securitiesApi.getAll({ 
      page, 
      search, 
      exchange, 
      security_type: securityType 
    }),
  });

  // Subscribe to real-time market data
  useEffect(() => {
    if (data?.data) {
      const symbols = data.data.map((s: Security) => s.symbol);
      
      if (symbols.length > 0) {
        actionCableService.subscribeToMarket(symbols, (quoteUpdate) => {
          setQuotes(prev => ({
            ...prev,
            [quoteUpdate.symbol]: quoteUpdate
          }));
        });
      }
    }

    return () => {
      actionCableService.unsubscribeAll();
    };
  }, [data]);

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <div className="bg-red-900/20 border border-red-500 rounded-lg p-4">
        <p className="text-red-400">Failed to load securities: {(error as Error).message}</p>
        <button 
          onClick={() => refetch()}
          className="mt-2 px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
        >
          Retry
        </button>
      </div>
    );
  }

  const securities = data?.data || [];
  const meta = data?.meta;

  const getQuoteValue = (security: Security, field: string) => {
    const liveQuote = quotes[security.symbol];
    const dbQuote = security.latest_quote;
    
    if (liveQuote && liveQuote[field] !== undefined) {
      return liveQuote[field];
    }
    return dbQuote?.[field];
  };

  const getChangeColor = (changePercent: number | undefined) => {
    if (!changePercent) return 'text-gray-400';
    return changePercent >= 0 ? 'text-green-400' : 'text-red-400';
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-white">Securities</h1>
        <div className="flex items-center space-x-2">
          <span className="text-sm text-gray-400">
            {meta?.total_count || 0} securities
          </span>
          <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" title="Live updates active"></div>
        </div>
      </div>

      {/* Filters */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        {/* Search */}
        <input
          type="text"
          value={search}
          onChange={(e) => {
            setSearch(e.target.value);
            setPage(1);
          }}
          className="px-4 py-2 rounded bg-gray-900 border border-gray-700 text-white placeholder-gray-400 focus:outline-none focus:border-blue-500"
          placeholder="Search by symbol or name..."
        />

        {/* Exchange Filter */}
        <select
          value={exchange}
          onChange={(e) => {
            setExchange(e.target.value);
            setPage(1);
          }}
          className="px-4 py-2 rounded bg-gray-900 border border-gray-700 text-white focus:outline-none focus:border-blue-500"
        >
          <option value="">All Exchanges</option>
          <option value="NSE">Nairobi Securities Exchange</option>
          <option value="USE">Uganda Securities Exchange</option>
          <option value="DSE">Dar es Salaam Stock Exchange</option>
        </select>

        {/* Security Type Filter */}
        <select
          value={securityType}
          onChange={(e) => {
            setSecurityType(e.target.value);
            setPage(1);
          }}
          className="px-4 py-2 rounded bg-gray-900 border border-gray-700 text-white focus:outline-none focus:border-blue-500"
        >
          <option value="">All Types</option>
          <option value="stock">Stocks</option>
          <option value="bond">Bonds</option>
          <option value="etf">ETFs</option>
        </select>

        {/* Clear Filters */}
        {(search || exchange || securityType) && (
          <button
            onClick={() => {
              setSearch('');
              setExchange('');
              setSecurityType('');
              setPage(1);
            }}
            className="px-4 py-2 bg-gray-800 text-white rounded hover:bg-gray-700 transition-colors"
          >
            Clear Filters
          </button>
        )}
      </div>

      {/* Securities Table */}
      {securities.length === 0 ? (
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-12 text-center">
          <p className="text-gray-400">No securities found</p>
          {(search || exchange || securityType) && (
            <p className="text-sm text-gray-500 mt-2">Try adjusting your filters</p>
          )}
        </div>
      ) : (
        <div className="bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-800 bg-gray-800/50">
                  <th className="px-4 py-3 text-left text-sm font-medium text-gray-400">Symbol</th>
                  <th className="px-4 py-3 text-left text-sm font-medium text-gray-400">Name</th>
                  <th className="px-4 py-3 text-left text-sm font-medium text-gray-400">Exchange</th>
                  <th className="px-4 py-3 text-left text-sm font-medium text-gray-400">Type</th>
                  <th className="px-4 py-3 text-right text-sm font-medium text-gray-400">Last Price</th>
                  <th className="px-4 py-3 text-right text-sm font-medium text-gray-400">Change</th>
                  <th className="px-4 py-3 text-right text-sm font-medium text-gray-400">Volume</th>
                  <th className="px-4 py-3 text-center text-sm font-medium text-gray-400">Status</th>
                </tr>
              </thead>
              <tbody>
                {securities.map((security: Security) => {
                  const lastPrice = getQuoteValue(security, 'last_price');
                  const changePercent = getQuoteValue(security, 'change_percent');
                  const volume = getQuoteValue(security, 'volume');
                  const isLive = quotes[security.symbol] !== undefined;

                  return (
                    <tr 
                      key={security.id} 
                      className="border-b border-gray-800 hover:bg-gray-800/30 transition-colors"
                    >
                      <td className="px-4 py-3">
                        <Link 
                          to={`/securities/${security.id}`}
                          className="font-medium text-blue-400 hover:text-blue-300 flex items-center"
                        >
                          {security.symbol}
                          {isLive && (
                            <span className="ml-2 w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" 
                              title="Live quote"></span>
                          )}
                        </Link>
                      </td>
                      <td className="px-4 py-3 text-white text-sm">{security.name}</td>
                      <td className="px-4 py-3 text-gray-400 text-sm">
                        {security.exchange?.code || 'N/A'}
                      </td>
                      <td className="px-4 py-3">
                        <span className="px-2 py-1 rounded text-xs font-medium bg-gray-700 text-gray-300 capitalize">
                          {security.security_type}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-right font-medium text-white">
                        {lastPrice ? `KES ${lastPrice.toFixed(2)}` : '-'}
                      </td>
                      <td className={`px-4 py-3 text-right font-medium ${getChangeColor(changePercent)}`}>
                        {changePercent !== undefined ? (
                          <>
                            {changePercent >= 0 ? '+' : ''}
                            {changePercent.toFixed(2)}%
                          </>
                        ) : '-'}
                      </td>
                      <td className="px-4 py-3 text-right text-gray-400 text-sm">
                        {volume ? volume.toLocaleString() : '-'}
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className={`px-2 py-1 rounded text-xs font-medium ${
                          security.status === 'active' 
                            ? 'bg-green-900/30 text-green-400' 
                            : 'bg-gray-700 text-gray-400'
                        }`}>
                          {security.status}
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Pagination */}
      {meta && meta.total_pages > 1 && (
        <div className="flex items-center justify-between">
          <button
            onClick={() => setPage(p => Math.max(1, p - 1))}
            disabled={page === 1}
            className="px-4 py-2 bg-gray-800 text-white rounded hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            Previous
          </button>
          
          <div className="flex items-center space-x-2">
            <span className="text-gray-400 text-sm">
              Page {meta.current_page} of {meta.total_pages}
            </span>
            <span className="text-gray-600 text-sm">
              ({meta.total_count} total)
            </span>
          </div>

          <button
            onClick={() => setPage(p => p + 1)}
            disabled={page >= meta.total_pages}
            className="px-4 py-2 bg-gray-800 text-white rounded hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            Next
          </button>
        </div>
      )}
    </div>
  );
};

export default SecuritiesList;
