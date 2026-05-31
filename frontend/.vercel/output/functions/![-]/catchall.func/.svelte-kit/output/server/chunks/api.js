import { z as writable } from "./index-server.js";
import "./index-server2.js";
//#region src/lib/stores.js
function createAuthStore() {
	const { subscribe, set, update } = writable({
		user: null,
		loading: true,
		authenticated: false
	});
	return {
		subscribe,
		login(user) {
			set({
				user,
				loading: false,
				authenticated: true
			});
		},
		logout() {
			set({
				user: null,
				loading: false,
				authenticated: false
			});
		},
		setLoading(loading) {
			update((state) => ({
				...state,
				loading
			}));
		},
		setUser(user) {
			set({
				user,
				loading: false,
				authenticated: Boolean(user)
			});
		}
	};
}
function createToastStore() {
	const { subscribe, update } = writable([]);
	return {
		subscribe,
		addToast(message, type = "info") {
			const id = crypto.randomUUID();
			update((items) => [...items, {
				id,
				message,
				type
			}]);
			setTimeout(() => this.removeToast(id), 4500);
			return id;
		},
		removeToast(id) {
			update((items) => items.filter((item) => item.id !== id));
		}
	};
}
function createFeedStore() {
	const { subscribe, set, update } = writable({
		videos: [],
		cursor: null,
		hasMore: true,
		filters: {}
	});
	return {
		subscribe,
		reset(filters = {}) {
			set({
				videos: [],
				cursor: null,
				hasMore: true,
				filters
			});
		},
		append(videos, cursor) {
			update((state) => ({
				...state,
				videos: [...state.videos, ...videos],
				cursor,
				hasMore: Boolean(cursor)
			}));
		},
		prepend(videos) {
			update((state) => ({
				...state,
				videos: [...videos, ...state.videos]
			}));
		},
		setFilters(filters) {
			update((state) => ({
				...state,
				filters
			}));
		}
	};
}
var authStore = createAuthStore();
var toastStore = createToastStore();
createFeedStore();
//#endregion
//#region src/lib/api.js
var API_BASE = "http://localhost:4000";
function csrfToken() {
	return "";
}
async function request(method, path, body) {
	const headers = { "Content-Type": "application/json" };
	if (!["GET", "HEAD"].includes(method)) headers["X-CSRF-Token"] = csrfToken();
	try {
		const response = await fetch(`${API_BASE}${path}`, {
			method,
			credentials: "include",
			headers,
			body: body === void 0 ? void 0 : JSON.stringify(body)
		});
		const data = await response.json().catch(() => ({}));
		if (response.status === 401 && false);
		if (response.status === 429) toastStore.addToast("Слишком много запросов. Попробуйте чуть позже.", "warning");
		if (!response.ok) throw Object.assign(new Error(data.error || "request_failed"), {
			status: response.status,
			data
		});
		return data;
	} catch (error) {
		if (!error.status) toastStore.addToast("Ошибка сети. Проверьте подключение.", "error");
		throw error;
	}
}
var get = (path) => request("GET", path);
var post = (path, body = {}) => request("POST", path, body);
var put = (path, body = {}) => request("PUT", path, body);
var del = (path) => request("DELETE", path);
var auth = {
	me: () => get("/api/auth/me"),
	login: (body) => post("/api/auth/login", body),
	register: (body) => post("/api/auth/register", body),
	logout: () => del("/api/auth/logout")
};
var feed = {
	list: (params = {}) => get(`/api/feed?${new URLSearchParams(clean(params))}`),
	recommendations: (limit = 3) => get(`/api/recommendations?${new URLSearchParams(clean({ limit }))}`)
};
var videos = {
	create: (body) => post("/api/videos", body),
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
var social = {
	follow: (id) => post(`/api/users/${id}/follow`),
	unfollow: (id) => del(`/api/users/${id}/follow`),
	like: (id) => post(`/api/videos/${id}/like`),
	unlike: (id) => del(`/api/videos/${id}/like`),
	save: (id) => post(`/api/videos/${id}/save`),
	unsave: (id) => del(`/api/videos/${id}/save`),
	comments: (id, cursor) => get(`/api/videos/${id}/comments?${new URLSearchParams(clean({ cursor }))}`),
	comment: (id, body, parent_id = null) => post(`/api/videos/${id}/comments`, {
		body,
		parent_id
	}),
	deleteComment: (id) => del(`/api/comments/${id}`),
	profile: (username) => get(`/api/users/${username}`),
	profileVideos: (username, params = {}) => get(`/api/users/${username}/videos?${new URLSearchParams(clean(params))}`)
};
var dashboard = {
	stats: () => get("/api/dashboard/stats"),
	history: (cursor) => get(`/api/dashboard/history?${new URLSearchParams(clean({ cursor }))}`),
	deleteHistory: (videoId) => del(`/api/dashboard/history/${videoId}`),
	saved: (cursor) => get(`/api/dashboard/saved?${new URLSearchParams(clean({ cursor }))}`),
	courses: () => get("/api/dashboard/courses"),
	exportData: () => get("/api/dashboard/export"),
	updateProfile: (body) => put("/api/settings/profile", body)
};
var search = { videos: (params = {}) => get(`/api/search?${new URLSearchParams(clean(params))}`) };
var courses = {
	list: (params = {}) => get(`/api/courses?${new URLSearchParams(clean(params))}`),
	detail: (slug) => get(`/api/courses/${slug}`),
	create: (body) => post("/api/courses", body),
	update: (id, body) => put(`/api/courses/${id}`, body),
	publish: (id) => post(`/api/courses/${id}/publish`),
	addVideo: (id, body) => post(`/api/courses/${id}/videos`, body),
	reorder: (id, video_ids) => put(`/api/courses/${id}/videos/reorder`, { video_ids }),
	progress: (id) => get(`/api/courses/${id}/progress`)
};
var payments = {
	access: (courseId) => get(`/api/courses/${courseId}/purchase`),
	purchase: (courseId) => post(`/api/courses/${courseId}/purchase`),
	onboarding: () => get("/api/creator/onboarding"),
	stats: () => get("/api/creator/stats"),
	payouts: () => get("/api/creator/payouts")
};
var notifications = {
	list: (cursor) => get(`/api/notifications?${new URLSearchParams(clean({ cursor }))}`),
	unreadCount: () => get("/api/notifications/unread-count"),
	markRead: (id) => post(`/api/notifications/${id}/read`),
	markAllRead: () => post("/api/notifications/read-all")
};
var messaging = {
	conversations: () => get("/api/conversations"),
	create: (user_id) => post("/api/conversations", { user_id }),
	messages: (id, cursor) => get(`/api/conversations/${id}/messages?${new URLSearchParams(clean({ cursor }))}`),
	send: (id, body) => post(`/api/conversations/${id}/messages`, body),
	read: (id) => post(`/api/conversations/${id}/read`),
	createGroup: (body) => post("/api/groups", body),
	addMember: (id, user_id) => post(`/api/groups/${id}/members`, { user_id }),
	removeMember: (id, user_id) => del(`/api/groups/${id}/members/${user_id}`),
	updateGroup: (id, body) => put(`/api/groups/${id}`, body)
};
function clean(obj) {
	return Object.fromEntries(Object.entries(obj).filter(([, value]) => value !== void 0 && value !== null && value !== ""));
}
//#endregion
export { messaging as a, search as c, authStore as d, toastStore as f, feed as i, social as l, courses as n, notifications as o, dashboard as r, payments as s, auth as t, videos as u };
