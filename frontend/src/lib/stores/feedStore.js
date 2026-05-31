import { writable } from 'svelte/store';
import { api } from '$lib/api';

function createFeedStore() {
  const { subscribe, update, set } = writable({ videos: [], cursor: null, hasMore: true, filters: {}, loading: false });
  return {
    subscribe,
    setFilters(filters) {
      set({ videos: [], cursor: null, hasMore: true, filters, loading: false });
    },
    async loadMore(state) {
      if (state.loading || !state.hasMore) return;
      update((s) => ({ ...s, loading: true }));
      const qs = new URLSearchParams({ ...state.filters, ...(state.cursor ? { cursor: state.cursor } : {}) });
      const page = await api(`/api/feed?${qs}`);
      update((s) => ({ ...s, videos: [...s.videos, ...page.items], cursor: page.cursor, hasMore: page.has_more, loading: false }));
    },
    prepend(video) {
      update((s) => ({ ...s, videos: [video, ...s.videos] }));
    }
  };
}

export const feedStore = createFeedStore();
