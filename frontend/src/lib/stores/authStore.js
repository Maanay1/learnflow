import { writable } from 'svelte/store';
import { api } from '$lib/api';

function createAuthStore() {
  const { subscribe, set, update } = writable({ user: null, isLoading: true, isAuthenticated: false });
  return {
    subscribe,
    async load() {
      try {
        const { user } = await api('/api/auth/me');
        set({ user, isLoading: false, isAuthenticated: !!user });
      } catch {
        set({ user: null, isLoading: false, isAuthenticated: false });
      }
    },
    setUser(user) {
      set({ user, isLoading: false, isAuthenticated: !!user });
    },
    patchUser(values) {
      update((state) => ({ ...state, user: { ...state.user, ...values } }));
    }
  };
}

export const authStore = createAuthStore();
