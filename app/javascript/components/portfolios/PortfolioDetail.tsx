import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { portfoliosApi } from '@/services/api';
import { Position } from '@/types';

const PortfolioDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  const { data, isLoading, error } = useQuery({
    queryKey: ['portfolio', id],
    queryFn: () => portfoliosApi.getById(parseInt(id!)),
    enabled: !!id,
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
        <p className="text-red-400">Failed to load portfolio</p>
      </div>
    );
  }

  const portfolio = data?.data;
  const positions = portfolio?.positions || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <button
            onClick={() => navigate('/portfolios')}
            className="text-gray-400 hover:text-white mb-2"
          >
            ← Back to Portfolios
          </button>
          <h1 className="text-3xl font-bold text-white">{portfolio?.name}</h1>
          {portfolio?.description && (
            <p className="text-gray-400 mt-1">{portfolio.description}</p>
          )}
        </div>
      </div>

      {/* Portfolio Summary */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Total Value</div>
          <div className="mt-2 text-3xl font-bold text-white">
            KES {portfolio?.total_value?.toLocaleString() || '0'}
          </div>
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Total Cost</div>
          <div className="mt-2 text-3xl font-bold text-white">
            KES {portfolio?.total_cost?.toLocaleString() || '0'}
          </div>
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Unrealized P&L</div>
          <div className={`mt-2 text-3xl font-bold ${
            (portfolio?.total_profit_loss || 0) >= 0 ? 'text-green-400' : 'text-red-400'
          }`}>
            {(portfolio?.total_profit_loss || 0) >= 0 ? '+' : ''}
            KES {portfolio?.total_profit_loss?.toLocaleString() || '0'}
          </div>
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-lg p-6">
          <div className="text-gray-400 text-sm font-medium">Return</div>
          <div className={`mt-2 text-3xl font-bold ${
            (portfolio?.total_profit_loss_percentage || 0) >= 0 ? 'text-green-400' : 'text-red-400'
          }`}>
            {(portfolio?.total_profit_loss_percentage || 0) >= 0 ? '+' : ''}
            {portfolio?.total_profit_loss_percentage?.toFixed(2)}%
          </div>
        </div>
      </div>

      {/* Positions Table */}
      <div className="bg-gray-900 border border-gray-800 rounded-lg overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-800">
          <h2 className="text-xl font-bold text-white">Positions</h2>
        </div>

        {positions.length === 0 ? (
          <div className="p-8 text-center text-gray-400">
            No positions in this portfolio yet.
            <div className="mt-4">
              <Link
                to="/orders/new"
                className="inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-md text-white font-medium transition-colors"
              >
                Create Order
              </Link>
            </div>
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
                    Quantity
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Avg Cost
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Total Cost
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Current Price
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Current Value
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    P&L
                  </th>
                  <th className="px-6 py-3 text-right text-sm font-medium text-gray-400">
                    Return %
                  </th>
                </tr>
              </thead>
              <tbody>
                {positions.map((position: Position) => (
                  <tr key={position.id} className="border-b border-gray-800 hover:bg-gray-800/50">
                    <td className="px-6 py-4">
                      <Link
                        to={`/securities/${position.security.id}`}
                        className="block hover:text-blue-400"
                      >
                        <div className="font-medium text-white">
                          {position.security.symbol}
                        </div>
                        <div className="text-sm text-gray-400">
                          {position.security.name}
                        </div>
                      </Link>
                    </td>
                    <td className="px-6 py-4 text-right text-white">
                      {position.quantity?.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 text-right text-white">
                      KES {position.average_cost?.toFixed(2)}
                    </td>
                    <td className="px-6 py-4 text-right text-white">
                      KES {(position.quantity * position.average_cost)?.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 text-right text-white">
                      KES {position.security.latest_quote?.last_price?.toFixed(2) || '-'}
                    </td>
                    <td className="px-6 py-4 text-right text-white font-medium">
                      KES {position.current_value?.toLocaleString() || '-'}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className={`font-bold ${
                        (position.profit_loss || 0) >= 0 ? 'text-green-400' : 'text-red-400'
                      }`}>
                        {(position.profit_loss || 0) >= 0 ? '+' : ''}
                        KES {position.profit_loss?.toLocaleString() || '0'}
                      </div>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className={`font-medium ${
                        (position.profit_loss_percentage || 0) >= 0 ? 'text-green-400' : 'text-red-400'
                      }`}>
                        {(position.profit_loss_percentage || 0) >= 0 ? '+' : ''}
                        {position.profit_loss_percentage?.toFixed(2)}%
                      </div>
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

export default PortfolioDetail;
