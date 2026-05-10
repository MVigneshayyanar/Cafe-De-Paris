import { writable } from 'svelte/store';

function createNotificationStore() {
  const { subscribe, set, update } = writable({
    alerts: [],
    unreadCount: 3
  });

  return {
    subscribe,
    addAlert: (alert) => update(s => ({
      ...s,
      alerts: [alert, ...s.alerts],
      unreadCount: s.unreadCount + 1
    })),
    markRead: () => update(s => ({ ...s, unreadCount: 0 })),
    setAlerts: (alerts) => set({ alerts, unreadCount: alerts.filter(a => !a.read).length })
  };
}

export const notifications = createNotificationStore();
