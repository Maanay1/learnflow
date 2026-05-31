import { writable } from 'svelte/store';

function createAuthStore() {
  const { subscribe, set, update } = writable({ user: null, loading: true, authenticated: false });

  return {
    subscribe,
    login(user) {
      set({ user, loading: false, authenticated: true });
    },
    logout() {
      set({ user: null, loading: false, authenticated: false });
    },
    setLoading(loading) {
      update((state) => ({ ...state, loading }));
    },
    setUser(user) {
      set({ user, loading: false, authenticated: Boolean(user) });
    }
  };
}

function createToastStore() {
  const { subscribe, update } = writable([]);

  return {
    subscribe,
    addToast(message, type = 'info') {
      const id = crypto.randomUUID();
      update((items) => [...items, { id, message, type }]);
      setTimeout(() => this.removeToast(id), 4500);
      return id;
    },
    removeToast(id) {
      update((items) => items.filter((item) => item.id !== id));
    }
  };
}

function createFeedStore() {
  const { subscribe, set, update } = writable({ videos: [], cursor: null, hasMore: true, filters: {} });

  return {
    subscribe,
    reset(filters = {}) {
      set({ videos: [], cursor: null, hasMore: true, filters });
    },
    append(videos, cursor) {
      update((state) => ({ ...state, videos: [...state.videos, ...videos], cursor, hasMore: Boolean(cursor) }));
    },
    prepend(videos) {
      update((state) => ({ ...state, videos: [...videos, ...state.videos] }));
    },
    setFilters(filters) {
      update((state) => ({ ...state, filters }));
    }
  };
}

export const authStore = createAuthStore();
export const toastStore = createToastStore();
export const feedStore = createFeedStore();
