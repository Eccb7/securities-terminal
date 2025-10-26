import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { alertRulesApi, securitiesApi } from '@/services/api';
import { AlertRule } from '@/types';

const AlertsList: React.FC = () => {
  const queryClient = useQueryClient();
  const [showForm, setShowForm] = useState(false);
  const [editingAlert, setEditingAlert] = useState<AlertRule | null>(null);
  const [formData, setFormData] = useState({
    security_id: '',
    condition_type: 'price_above',
    condition_value: '',
    message: '',
    active: true,
  });

  const { data, isLoading, error } = useQuery({
    queryKey: ['alertRules'],
    queryFn: () => alertRulesApi.getAll(),
  });

  const { data: securitiesData } = useQuery({
    queryKey: ['securities'],
    queryFn: () => securitiesApi.getAll({ per_page: 100 }),
  });

  const createMutation = useMutation({
    mutationFn: alertRulesApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alertRules'] });
      resetForm();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<AlertRule> }) =>
      alertRulesApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alertRules'] });
      resetForm();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: alertRulesApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alertRules'] });
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: ({ id, active }: { id: number; active: boolean }) =>
      alertRulesApi.update(id, { active }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alertRules'] });
    },
  });

  const resetForm = () => {
    setFormData({
      security_id: '',
      condition_type: 'price_above',
      condition_value: '',
      message: '',
      active: true,
    });
    setShowForm(false);
    setEditingAlert(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const submitData = {
      ...formData,
      security_id: parseInt(formData.security_id),
      condition_value: parseFloat(formData.condition_value),
    };

    if (editingAlert) {
      updateMutation.mutate({ id: editingAlert.id, data: submitData });
    } else {
      createMutation.mutate(submitData);
    }
  };

  const handleEdit = (alert: AlertRule) => {
    setEditingAlert(alert);
    setFormData({
      security_id: alert.security_id.toString(),
      condition_type: alert.condition_type,
      condition_value: alert.condition_value.toString(),
      message: alert.message || '',
      active: alert.active,
    });
    setShowForm(true);
  };

  const handleDelete = (id: number) => {
    if (confirm('Are you sure you want to delete this alert?')) {
      deleteMutation.mutate(id);
    }
  };

  const handleToggleActive = (id: number, active: boolean) => {
    toggleActiveMutation.mutate({ id, active: !active });
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
        <p className="text-red-400">Failed to load alerts</p>
      </div>
    );
  }

  const alertRules = data?.data || [];
  const securities = securitiesData?.data || [];

  const getConditionLabel = (type: string) => {
    const labels: Record<string, string> = {
      price_above: 'Price Above',
      price_below: 'Price Below',
      volume_spike: 'Volume Spike',
      percent_change: 'Percent Change',
    };
    return labels[type] || type;
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold text-white">Alert Rules</h1>
        <button
          onClick={() => setShowForm(!showForm)}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md"
        >
          {showForm ? 'Cancel' : 'New Alert'}
        </button>
      </div>

      {/* Create/Edit Form */}
      {showForm && (
        <form
          onSubmit={handleSubmit}
          className="bg-gray-900 border border-gray-800 rounded-lg p-6 space-y-4"
        >
          <h3 className="text-lg font-semibold text-white">
            {editingAlert ? 'Edit Alert Rule' : 'Create Alert Rule'}
          </h3>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Security *
              </label>
              <select
                required
                value={formData.security_id}
                onChange={(e) =>
                  setFormData({ ...formData, security_id: e.target.value })
                }
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select a security</option>
                {securities.map((security) => (
                  <option key={security.id} value={security.id}>
                    {security.symbol} - {security.name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Condition Type *
              </label>
              <select
                required
                value={formData.condition_type}
                onChange={(e) =>
                  setFormData({ ...formData, condition_type: e.target.value })
                }
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="price_above">Price Above</option>
                <option value="price_below">Price Below</option>
                <option value="volume_spike">Volume Spike</option>
                <option value="percent_change">Percent Change</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Condition Value *
              </label>
              <input
                type="number"
                step="0.01"
                required
                value={formData.condition_value}
                onChange={(e) =>
                  setFormData({ ...formData, condition_value: e.target.value })
                }
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter value"
              />
            </div>

            <div className="flex items-center">
              <label className="flex items-center space-x-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={formData.active}
                  onChange={(e) =>
                    setFormData({ ...formData, active: e.target.checked })
                  }
                  className="w-4 h-4 text-blue-600 bg-gray-800 border-gray-700 rounded focus:ring-2 focus:ring-blue-500"
                />
                <span className="text-sm text-gray-400">Active</span>
              </label>
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-400 mb-2">
                Custom Message
              </label>
              <textarea
                value={formData.message}
                onChange={(e) =>
                  setFormData({ ...formData, message: e.target.value })
                }
                rows={2}
                className="w-full px-4 py-2 bg-gray-800 border border-gray-700 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Optional custom alert message"
              />
            </div>
          </div>

          <div className="flex justify-end gap-2">
            <button
              type="button"
              onClick={resetForm}
              className="px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded-md"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={createMutation.isPending || updateMutation.isPending}
              className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md disabled:opacity-50"
            >
              {editingAlert ? 'Update' : 'Create'} Alert
            </button>
          </div>

          {(createMutation.error || updateMutation.error) && (
            <div className="bg-red-900/20 border border-red-500 rounded-lg p-3">
              <p className="text-red-400 text-sm">
                Failed to {editingAlert ? 'update' : 'create'} alert
              </p>
            </div>
          )}
        </form>
      )}

      {/* Alert Rules List */}
      {alertRules.length === 0 ? (
        <div className="bg-gray-900 border border-gray-800 rounded-lg p-8 text-center text-gray-400">
          No alert rules found. Create one to get started.
        </div>
      ) : (
        <div className="space-y-4">
          {alertRules.map((alert: AlertRule) => (
            <div
              key={alert.id}
              className="bg-gray-900 border border-gray-800 rounded-lg p-6"
            >
              <div className="flex items-start justify-between">
                <div className="flex-1 space-y-2">
                  <div className="flex items-center gap-3">
                    <button
                      onClick={() => handleToggleActive(alert.id, alert.active)}
                      className={`px-3 py-1 rounded text-sm font-medium ${
                        alert.active
                          ? 'bg-green-900/30 text-green-400'
                          : 'bg-gray-700 text-gray-400'
                      }`}
                    >
                      {alert.active ? 'Active' : 'Inactive'}
                    </button>
                    {alert.security && (
                      <span className="text-blue-400 font-semibold">
                        {alert.security.symbol}
                      </span>
                    )}
                  </div>

                  <div className="text-white">
                    <span className="font-medium">
                      {getConditionLabel(alert.condition_type)}
                    </span>
                    <span className="mx-2">:</span>
                    <span className="text-lg font-bold">
                      {alert.condition_value}
                    </span>
                  </div>

                  {alert.message && (
                    <p className="text-gray-400 text-sm">{alert.message}</p>
                  )}

                  {alert.last_triggered_at && (
                    <p className="text-xs text-gray-500">
                      Last triggered:{' '}
                      {new Date(alert.last_triggered_at).toLocaleString()}
                    </p>
                  )}
                </div>

                <div className="flex gap-2">
                  <button
                    onClick={() => handleEdit(alert)}
                    className="px-3 py-1 bg-gray-700 hover:bg-gray-600 text-white rounded text-sm"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => handleDelete(alert.id)}
                    className="px-3 py-1 bg-red-900/30 hover:bg-red-900/50 text-red-400 rounded text-sm"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default AlertsList;
