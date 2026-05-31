import { writable } from 'svelte/store';

function createNotificationStore() {
  const { subscribe, update } = writable({ items: [] });
  return {
    subscribe,
    push(message) {
      const id = crypto.randomUUID();
      update((s) => ({ items: [...s.items, { id, message }] }));
      setTimeout(() => update((s) => ({ items: s.items.filter((item) => item.id !== id) })), 4000);
    }
  };
}

export const notificationStore = createNotificationStore();
