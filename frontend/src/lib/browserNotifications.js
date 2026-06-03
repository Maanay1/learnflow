import { browser } from '$app/environment';

export async function registerServiceWorker() {
  if (!browser || !('serviceWorker' in navigator)) return null;
  return navigator.serviceWorker.register('/sw.js').catch(() => null);
}

export async function ensureNotificationPermission() {
  if (!browser || !('Notification' in window)) return 'unsupported';
  if (Notification.permission === 'default') return Notification.requestPermission();
  return Notification.permission;
}

export async function showBrowserNotification(title, options = {}) {
  if (!browser || !('Notification' in window) || Notification.permission !== 'granted') return;

  const payload = {
    icon: '/jarq-icon.svg',
    badge: '/jarq-icon.svg',
    ...options
  };

  if ('serviceWorker' in navigator) {
    const registration = await navigator.serviceWorker.ready.catch(() => null);
    if (registration?.showNotification) return registration.showNotification(title, payload);
  }

  return new Notification(title, payload);
}
