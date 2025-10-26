import React, { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { ordersApi, securitiesApi, portfoliosApi } from '@/services/api';

const OrderForm: React.FC = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const [formData, setFormData] = useState({
    security_id: '',
    portfolio_id: '',
    order_type: 'market',
    side: 'buy',
    quantity: '',
    price: '',
    stop_price: '',
    time_in_force: 'day',
    notes: '',
  });

  const [errors, setErrors] = useState<string[]>([]);

  // Fetch securities for selection
  const { data: securitiesData } = useQuery({
    queryKey: ['securities'],
    queryFn: () => securitiesApi.getAll({}),
  });

  // Fetch portfolios for selection
  const { data: portfoliosData } = useQuery({
    queryKey: ['portfolios'],
    queryFn: () => portfoliosApi.getAll(),
  });

  const createMutation = useMutation({
    mutationFn: (data: any) => ordersApi.create({ order: data }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      navigate('/orders');
    },
    onError: (error: any) => {
      setErrors(error.response?.data?.errors || ['Failed to create order']);
    },
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrors([]);

    // Validate
    const newErrors: string[] = [];
    if (!formData.security_id) newErrors.push('Security is required');
    if (!formData.portfolio_id) newErrors.push('Portfolio is required');
    if (!formData.quantity || parseInt(formData.quantity) <= 0) newErrors.push('Quantity must be greater than 0');
    if (formData.order_type !== 'market' && (!formData.price || parseFloat(formData.price) <= 0)) {
      newErrors.push('Price is required for limit and stop orders');
    }

    if (newErrors.length > 0) {
      setErrors(newErrors);
      return;
    }

    // Prepare data
    const orderData = {
      security_id: parseInt(formData.security_id),
      portfolio_id: parseInt(formData.portfolio_id),
      order_type: formData.order_type,
      side: formData.side,
      quantity: parseInt(formData.quantity),
      price: formData.price ? parseFloat(formData.price) : null,
      stop_price: formData.stop_price ? parseFloat(formData.stop_price) : null,
      time_in_force: formData.time_in_force,
      notes: formData.notes || null,
    };

    await createMutation.mutateAsync(orderData);
  };

  const calculateTotal = () => {
    const quantity = parseInt(formData.quantity) || 0;
    const price = parseFloat(formData.price) || 0;
    return (quantity * price).toFixed(2);
  };

  const securities = securitiesData?.data || [];
  const portfolios = portfoliosData?.data || [];

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-white">New Order</h1>
        <button
          onClick={() => navigate('/orders')}
          className="text-gray-400 hover:text-white"
        >
          ← Back to Orders
        </button>
      </div>

      {/* Errors */}
      {errors.length > 0 && (
        <div className="bg-red-900/20 border border-red-500 rounded-lg p-4">
          <ul className="list-disc list-inside text-red-400">
            {errors.map((error, index) => (
              <li key={index}>{error}</li>
            ))}
          </ul>
        </div>
      )}

      {/* Form */}
      <form onSubmit={handleSubmit} className="bg-gray-900 border border-gray-800 rounded-lg p-6 space-y-6">
        {/* Security Selection */}
        <div>
          <label className="block text-sm font-medium text-gray-400 mb-2">
            Security *
          </label>
          <select
            name="security_id"
            value={formData.security_id}
            onChange={handleChange}
            required
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Select a security</option>
            {securities.map((security: any) => (
              <option key={security.id} value={security.id}>
                {security.symbol} - {security.name}
              </option>
            ))}
          </select>
        </div>

        {/* Portfolio Selection */}
        <div>
          <label className="block text-sm font-medium text-gray-400 mb-2">
            Portfolio *
          </label>
          <select
            name="portfolio_id"
            value={formData.portfolio_id}
            onChange={handleChange}
            required
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Select a portfolio</option>
            {portfolios.map((portfolio: any) => (
              <option key={portfolio.id} value={portfolio.id}>
                {portfolio.name}
              </option>
            ))}
          </select>
        </div>

        {/* Order Type and Side */}
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">
              Order Type *
            </label>
            <select
              name="order_type"
              value={formData.order_type}
              onChange={handleChange}
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="market">Market</option>
              <option value="limit">Limit</option>
              <option value="stop">Stop</option>
              <option value="stop_limit">Stop Limit</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">
              Side *
            </label>
            <select
              name="side"
              value={formData.side}
              onChange={handleChange}
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="buy">Buy</option>
              <option value="sell">Sell</option>
            </select>
          </div>
        </div>

        {/* Quantity and Price */}
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">
              Quantity *
            </label>
            <input
              type="number"
              name="quantity"
              value={formData.quantity}
              onChange={handleChange}
              min="1"
              required
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="0"
            />
          </div>

          {formData.order_type !== 'market' && (
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Price *
              </label>
              <input
                type="number"
                name="price"
                value={formData.price}
                onChange={handleChange}
                step="0.01"
                min="0"
                required={formData.order_type !== 'market'}
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="0.00"
              />
            </div>
          )}
        </div>

        {/* Stop Price (for stop orders) */}
        {(formData.order_type === 'stop' || formData.order_type === 'stop_limit') && (
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-2">
              Stop Price
            </label>
            <input
              type="number"
              name="stop_price"
              value={formData.stop_price}
              onChange={handleChange}
              step="0.01"
              min="0"
              className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="0.00"
            />
          </div>
        )}

        {/* Time in Force */}
        <div>
          <label className="block text-sm font-medium text-gray-400 mb-2">
            Time in Force
          </label>
          <select
            name="time_in_force"
            value={formData.time_in_force}
            onChange={handleChange}
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="day">Day</option>
            <option value="gtc">Good Till Cancelled (GTC)</option>
            <option value="ioc">Immediate or Cancel (IOC)</option>
            <option value="fok">Fill or Kill (FOK)</option>
          </select>
        </div>

        {/* Notes */}
        <div>
          <label className="block text-sm font-medium text-gray-400 mb-2">
            Notes
          </label>
          <textarea
            name="notes"
            value={formData.notes}
            onChange={handleChange}
            rows={3}
            className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Optional notes..."
          />
        </div>

        {/* Total Cost */}
        {formData.quantity && formData.price && (
          <div className="bg-gray-800 rounded-lg p-4">
            <div className="flex items-center justify-between">
              <span className="text-gray-400">Estimated Total:</span>
              <span className="text-2xl font-bold text-white">
                KES {calculateTotal()}
              </span>
            </div>
          </div>
        )}

        {/* Buttons */}
        <div className="flex gap-4">
          <button
            type="submit"
            disabled={createMutation.isPending}
            className="flex-1 px-6 py-3 bg-blue-600 hover:bg-blue-700 rounded-md text-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {createMutation.isPending ? 'Creating Order...' : 'Create Order'}
          </button>
          <button
            type="button"
            onClick={() => navigate('/orders')}
            className="px-6 py-3 bg-gray-800 hover:bg-gray-700 rounded-md text-white font-medium transition-colors"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
};

export default OrderForm;
