import { createConsumer, Subscription } from '@rails/actioncable';
import type { QuoteUpdate, OrderUpdate, AlertNotification } from '@/types';

class ActionCableService {
  private consumer: ReturnType<typeof createConsumer>;
  private subscriptions: Map<string, Subscription> = new Map();

  constructor() {
    this.consumer = createConsumer();
  }

  subscribeToMarketData(callbacks: {
    onQuoteReceived?: (data: QuoteUpdate) => void;
    onConnected?: () => void;
    onDisconnected?: () => void;
  }) {
    const subscription = this.consumer.subscriptions.create(
      { channel: 'MarketChannel' },
      {
        connected: () => {
          console.log('Connected to MarketChannel');
          callbacks.onConnected?.();
        },
        disconnected: () => {
          console.log('Disconnected from MarketChannel');
          callbacks.onDisconnected?.();
        },
        received: (data: QuoteUpdate) => {
          if (data.type === 'quote') {
            callbacks.onQuoteReceived?.(data);
          }
        },
      }
    );

    this.subscriptions.set('market', subscription);
    return subscription;
  }

  subscribeToOrders(callbacks: {
    onOrderUpdate?: (data: OrderUpdate) => void;
    onConnected?: () => void;
    onDisconnected?: () => void;
  }) {
    const subscription = this.consumer.subscriptions.create(
      { channel: 'OrderChannel' },
      {
        connected: () => {
          console.log('Connected to OrderChannel');
          callbacks.onConnected?.();
        },
        disconnected: () => {
          console.log('Disconnected from OrderChannel');
          callbacks.onDisconnected?.();
        },
        received: (data: OrderUpdate) => {
          if (data.type === 'order') {
            callbacks.onOrderUpdate?.(data);
          }
        },
      }
    );

    this.subscriptions.set('orders', subscription);
    return subscription;
  }

  subscribeToAlerts(callbacks: {
    onAlertReceived?: (data: AlertNotification) => void;
    onConnected?: () => void;
    onDisconnected?: () => void;
  }) {
    const subscription = this.consumer.subscriptions.create(
      { channel: 'AlertChannel' },
      {
        connected: () => {
          console.log('Connected to AlertChannel');
          callbacks.onConnected?.();
        },
        disconnected: () => {
          console.log('Disconnected from AlertChannel');
          callbacks.onDisconnected?.();
        },
        received: (data: AlertNotification) => {
          if (data.type === 'alert') {
            callbacks.onAlertReceived?.(data);
          }
        },
      }
    );

    this.subscriptions.set('alerts', subscription);
    return subscription;
  }

  unsubscribe(channel: string) {
    const subscription = this.subscriptions.get(channel);
    if (subscription) {
      subscription.unsubscribe();
      this.subscriptions.delete(channel);
    }
  }

  unsubscribeAll() {
    this.subscriptions.forEach((subscription) => {
      subscription.unsubscribe();
    });
    this.subscriptions.clear();
  }

  disconnect() {
    this.unsubscribeAll();
    this.consumer.disconnect();
  }
}

export const actionCableService = new ActionCableService();
