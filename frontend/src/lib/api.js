import { browser } from '$app/environment';
import { toastStore } from '$lib/stores';
export const API_BASE = (import.meta.env.VITE_API_URL || 'https://learnflow-api-1eef.onrender.com').replace(/\/+$/, '');

function csrfToken() {
  if (!browser) return '';
  const meta = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
  const cookie = document.cookie.split('; ').find((row) => row.startsWith('csrf_token='))?.split('=')[1];
  return meta || cookie || '';
}

async function request(method, path, body) {
  const headers = { 'Content-Type': 'application/json' };
  if (!['GET', 'HEAD'].includes(method)) headers['X-CSRF-Token'] = csrfToken();

  try {
    const response = await fetch(`${API_BASE}${path}`, {
      method,
      credentials: 'include',
      headers,
      body: body === undefined ? undefined : JSON.stringify(body)
    });

    const data = await response.json().catch(() => ({}));

    if (response.status === 401 && browser) {
      throw Object.assign(new Error('unauthorized'), { status: 401, data });
    }

    if (response.status === 429) {
      toastStore.addToast('Слишком много запросов. Попробуйте чуть позже.', 'warning');
    }

    if (!response.ok) {
      throw Object.assign(new Error(data.error || 'request_failed'), { status: response.status, data });
    }

    return data;
  } catch (error) { throw error; }
}

async function upload(path, formData) {
  const response = await fetch(`${API_BASE}${path}`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'X-CSRF-Token': csrfToken() },
    body: formData
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw Object.assign(new Error(data.error || 'request_failed'), { status: response.status, data });
  return data;
}

export const get = (path) => request('GET', path);
export const post = (path, body = {}) => request('POST', path, body);
export const put = (path, body = {}) => request('PUT', path, body);
export const del = (path) => request('DELETE', path);

export const auth = {
  me: () => get('/api/auth/me'),
  login: (body) => post('/api/auth/login', body),
  register: (body) => post('/api/auth/register', body),
  logout: () => del('/api/auth/logout')
};

export const feed = {
  list: (params = {}) => get(`/api/feed?${new URLSearchParams(clean(params))}`),
  recommendations: (limit = 3) => get(`/api/recommendations?${new URLSearchParams(clean({ limit }))}`)
};

export const videos = {
  create: (body) => post('/api/videos', body),
  detail: (slug) => get(`/api/videos/${slug}`),
  viewUrl: (id) => get(`/api/videos/${id}/view-url`),
  uploadUrl: (id, body) => post(`/api/videos/${id}/upload-url`, body),
  thumbnailUrl: (id, body) => post(`/api/videos/${id}/thumbnail-url`, body),
  confirm: (id, body) => post(`/api/videos/${id}/confirm`, body),
  chapters: (id, chapters) => post(`/api/videos/${id}/chapters`, { chapters }),
  progress: (id, seconds_watched) => post(`/api/videos/${id}/progress`, { seconds_watched }),
  complete: (id) => post(`/api/videos/${id}/complete`),
  subtitles: (id, lang) => get(`/api/videos/${id}/subtitles/${lang}`),
  summary: (id) => get(`/api/videos/${id}/summary`),
  transcribe: (id) => post(`/api/videos/${id}/transcribe`)
};

export const social = {
  follow: (id) => post(`/api/users/${id}/follow`),
  unfollow: (id) => del(`/api/users/${id}/follow`),
  like: (id) => post(`/api/videos/${id}/like`),
  unlike: (id) => del(`/api/videos/${id}/like`),
  save: (id) => post(`/api/videos/${id}/save`),
  unsave: (id) => del(`/api/videos/${id}/save`),
  comments: (id, cursor) => get(`/api/videos/${id}/comments?${new URLSearchParams(clean({ cursor }))}`),
  comment: (id, body, parent_id = null) => post(`/api/videos/${id}/comments`, { body, parent_id }),
  deleteComment: (id) => del(`/api/comments/${id}`),
  profile: (username) => get(`/api/users/${username}`),
  profileVideos: (username, params = {}) => get(`/api/users/${username}/videos?${new URLSearchParams(clean(params))}`),
  followers: (username) => get(`/api/users/${username}/followers`),
  following: (username) => get(`/api/users/${username}/following`)
};

export const dashboard = {
  stats: () => get('/api/dashboard/stats'),
  history: (cursor) => get(`/api/dashboard/history?${new URLSearchParams(clean({ cursor }))}`),
  deleteHistory: (videoId) => del(`/api/dashboard/history/${videoId}`),
  saved: (cursor) => get(`/api/dashboard/saved?${new URLSearchParams(clean({ cursor }))}`),
  courses: () => get('/api/dashboard/courses'),
  exportData: () => get('/api/dashboard/export'),
  updateProfile: (body) => put('/api/users/me', body),
  updatePassword: (body) => put('/api/users/me/password', body),
  uploadAvatar: (file) => { const form = new FormData(); form.append('avatar', file); return upload('/api/users/me/avatar', form); }
};

export const search = {
  videos: (params = {}) => get(`/api/search?${new URLSearchParams(clean(params))}`),
  users: (q = '') => get(`/api/users/search?${new URLSearchParams(clean({ q }))}`),
  usernameAvailable: (username) => get(`/api/users/username-available?${new URLSearchParams(clean({ username }))}`)
};

export const courses = {
  list: (params = {}) => get(`/api/courses?${new URLSearchParams(clean(params))}`),
  detail: (slug) => get(`/api/courses/${slug}`),
  create: (body) => post('/api/courses', body),
  update: (id, body) => put(`/api/courses/${id}`, body),
  publish: (id) => post(`/api/courses/${id}/publish`),
  addVideo: (id, body) => post(`/api/courses/${id}/videos`, body),
  reorder: (id, video_ids) => put(`/api/courses/${id}/videos/reorder`, { video_ids }),
  progress: (id) => get(`/api/courses/${id}/progress`)
};

export const certificates = {
  download: (id) => get(`/api/certificates/${id}/download`)
};

export const payments = {
  access: (courseId) => get(`/api/courses/${courseId}/purchase`),
  purchase: (courseId) => post(`/api/courses/${courseId}/purchase`),
  onboarding: () => get('/api/creator/onboarding'),
  stats: () => get('/api/creator/stats'),
  payouts: () => get('/api/creator/payouts')
};

export const notifications = {
  list: (cursor) => get(`/api/notifications?${new URLSearchParams(clean({ cursor }))}`),
  unreadCount: () => get('/api/notifications/unread-count'),
  markRead: (id) => post(`/api/notifications/${id}/read`),
  markAllRead: () => post('/api/notifications/read-all')
};

export const messaging = {
  conversations: () => get('/api/conversations'),
  create: (user_id) => post('/api/conversations', { user_id }),
  messages: (id, cursor) => get(`/api/conversations/${id}/messages?${new URLSearchParams(clean({ cursor }))}`),
  send: (id, body) => post(`/api/conversations/${id}/messages`, body),
  read: (id) => post(`/api/conversations/${id}/read`),
  createGroup: (body) => post('/api/groups', body),
  addMember: (id, user_id) => post(`/api/groups/${id}/members`, { user_id }),
  removeMember: (id, user_id) => del(`/api/groups/${id}/members/${user_id}`),
  updateGroup: (id, body) => put(`/api/groups/${id}`, body)
};

function clean(obj) {
  return Object.fromEntries(Object.entries(obj).filter(([, value]) => value !== undefined && value !== null && value !== ''));
}
