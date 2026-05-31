import { $ as escape_html, Z as attr, _ as sanitize_props, b as store_get, p as ensure_array_like, s as attr_class, v as slot, x as unsubscribe_stores, y as spread_props } from "../../chunks/index-server.js";
import { d as authStore, f as toastStore } from "../../chunks/api.js";
import { t as page } from "../../chunks/stores.js";
import { t as Icon } from "../../chunks/Icon.js";
import { t as Messages_square } from "../../chunks/messages-square.js";
import { t as Search } from "../../chunks/search.js";
import { t as Avatar } from "../../chunks/Avatar.js";
//#region node_modules/lucide-svelte/dist/icons/bell.svelte
function Bell($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "bell" },
		sanitize_props($$props),
		{
			/**
			* @component @name Bell
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTAuMjY4IDIxYTIgMiAwIDAgMCAzLjQ2NCAwIiAvPgogIDxwYXRoIGQ9Ik0zLjI2MiAxNS4zMjZBMSAxIDAgMCAwIDQgMTdoMTZhMSAxIDAgMCAwIC43NC0xLjY3M0MxOS40MSAxMy45NTYgMTggMTIuNDk5IDE4IDhBNiA2IDAgMCAwIDYgOGMwIDQuNDk5LTEuNDExIDUuOTU2LTIuNzM4IDcuMzI2IiAvPgo8L3N2Zz4K) - https://lucide.dev/icons/bell
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M10.268 21a2 2 0 0 0 3.464 0" }], ["path", { "d": "M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326" }]],
			children: ($$renderer) => {
				$$renderer.push(`<!--[-->`);
				slot($$renderer, $$props, "default", {}, null);
				$$renderer.push(`<!--]-->`);
			},
			$$slots: { default: true }
		}
	]));
}
//#endregion
//#region node_modules/lucide-svelte/dist/icons/house.svelte
function House($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "house" },
		sanitize_props($$props),
		{
			/**
			* @component @name House
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTUgMjF2LThhMSAxIDAgMCAwLTEtMWgtNGExIDEgMCAwIDAtMSAxdjgiIC8+CiAgPHBhdGggZD0iTTMgMTBhMiAyIDAgMCAxIC43MDktMS41MjhsNy01Ljk5OWEyIDIgMCAwIDEgMi41ODIgMGw3IDUuOTk5QTIgMiAwIDAgMSAyMSAxMHY5YTIgMiAwIDAgMS0yIDJINWEyIDIgMCAwIDEtMi0yeiIgLz4KPC9zdmc+Cg==) - https://lucide.dev/icons/house
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8" }], ["path", { "d": "M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" }]],
			children: ($$renderer) => {
				$$renderer.push(`<!--[-->`);
				slot($$renderer, $$props, "default", {}, null);
				$$renderer.push(`<!--]-->`);
			},
			$$slots: { default: true }
		}
	]));
}
//#endregion
//#region node_modules/lucide-svelte/dist/icons/plus.svelte
function Plus($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "plus" },
		sanitize_props($$props),
		{
			/**
			* @component @name Plus
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNNSAxMmgxNCIgLz4KICA8cGF0aCBkPSJNMTIgNXYxNCIgLz4KPC9zdmc+Cg==) - https://lucide.dev/icons/plus
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M5 12h14" }], ["path", { "d": "M12 5v14" }]],
			children: ($$renderer) => {
				$$renderer.push(`<!--[-->`);
				slot($$renderer, $$props, "default", {}, null);
				$$renderer.push(`<!--]-->`);
			},
			$$slots: { default: true }
		}
	]));
}
//#endregion
//#region node_modules/lucide-svelte/dist/icons/user.svelte
function User($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "user" },
		sanitize_props($$props),
		{
			/**
			* @component @name User
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTkgMjF2LTJhNCA0IDAgMCAwLTQtNEg5YTQgNCAwIDAgMC00IDR2MiIgLz4KICA8Y2lyY2xlIGN4PSIxMiIgY3k9IjciIHI9IjQiIC8+Cjwvc3ZnPgo=) - https://lucide.dev/icons/user
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" }], ["circle", {
				"cx": "12",
				"cy": "7",
				"r": "4"
			}]],
			children: ($$renderer) => {
				$$renderer.push(`<!--[-->`);
				slot($$renderer, $$props, "default", {}, null);
				$$renderer.push(`<!--]-->`);
			},
			$$slots: { default: true }
		}
	]));
}
//#endregion
//#region src/lib/components/Navbar.svelte
function Navbar($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let username, path, items;
		let unreadMessages = 0;
		function active(item) {
			return item.profile ? path.startsWith("/profile") : path === item.href || path.startsWith(`${item.href}/`);
		}
		$: username = store_get($$store_subs ??= {}, "$authStore", authStore).user?.username;
		$: path = store_get($$store_subs ??= {}, "$page", page).url.pathname;
		$: items = [
			{
				href: "/feed",
				label: "Главная",
				icon: House
			},
			{
				href: "/search",
				label: "Поиск",
				icon: Search
			},
			{
				href: "/upload",
				label: "Загрузить",
				icon: Plus,
				upload: true
			},
			{
				href: "/messages",
				label: "Чаты",
				icon: Messages_square,
				badge: unreadMessages
			},
			{
				href: "/notifications",
				label: "Уведомления",
				icon: Bell
			},
			{
				href: `/profile/${username}`,
				label: "Профиль",
				icon: User,
				profile: true
			}
		];
		$$renderer.push(`<aside class="sidebar desktop-sidebar svelte-rfuq4y"><a href="/feed" class="logo svelte-rfuq4y">LearnFlow</a> <nav class="desktop-nav svelte-rfuq4y"><!--[-->`);
		const each_array = ensure_array_like(items);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let item = each_array[$$index];
			$$renderer.push(`<a${attr_class("nav-item svelte-rfuq4y", void 0, {
				"active": active(item),
				"upload": item.upload
			})}${attr("href", item.href)}>`);
			if (item.icon) {
				$$renderer.push("<!--[-->");
				item.icon($$renderer, {
					size: 22,
					strokeWidth: 2.4
				});
				$$renderer.push("<!--]-->");
			} else {
				$$renderer.push("<!--[!-->");
				$$renderer.push("<!--]-->");
			}
			$$renderer.push(` <span>${escape_html(item.label)}</span> `);
			if (item.badge) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<small class="nav-badge svelte-rfuq4y">${escape_html(item.badge)}</small>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--></a>`);
		}
		$$renderer.push(`<!--]--></nav> `);
		if (store_get($$store_subs ??= {}, "$authStore", authStore).authenticated) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<a class="user-card svelte-rfuq4y"${attr("href", `/profile/${username}`)}>`);
			Avatar($$renderer, {
				user: store_get($$store_subs ??= {}, "$authStore", authStore).user,
				size: 36
			});
			$$renderer.push(`<!----> <span class="svelte-rfuq4y"><strong class="user-card-name svelte-rfuq4y">${escape_html(store_get($$store_subs ??= {}, "$authStore", authStore).user?.display_name || username)}</strong> <small class="user-card-handle svelte-rfuq4y">@${escape_html(username)}</small></span></a>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--></aside> <nav class="mobile-nav svelte-rfuq4y"><!--[-->`);
		const each_array_1 = ensure_array_like(items);
		for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
			let item = each_array_1[$$index_1];
			$$renderer.push(`<a${attr("href", item.href)}${attr("aria-label", item.label)}${attr_class("svelte-rfuq4y", void 0, {
				"active": active(item),
				"upload": item.upload
			})}>`);
			if (item.icon) {
				$$renderer.push("<!--[-->");
				item.icon($$renderer, {
					size: item.upload ? 25 : 22,
					strokeWidth: 2.5
				});
				$$renderer.push("<!--]-->");
			} else {
				$$renderer.push("<!--[!-->");
				$$renderer.push("<!--]-->");
			}
			$$renderer.push(` `);
			if (item.badge) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<small class="mobile-badge svelte-rfuq4y">${escape_html(item.badge)}</small>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			if (!item.upload) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<span>${escape_html(item.label)}</span>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--></a>`);
		}
		$$renderer.push(`<!--]--></nav>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
//#region src/lib/components/Toast.svelte
function Toast($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		$$renderer.push(`<div class="fixed right-4 top-4 z-50 space-y-3"><!--[-->`);
		const each_array = ensure_array_like(store_get($$store_subs ??= {}, "$toastStore", toastStore));
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let toast = each_array[$$index];
			$$renderer.push(`<button${attr_class(`block min-w-72 rounded-xl border px-4 py-3 text-left shadow-2xl ${toast.type === "error" ? "border-[#ef4444]/30 bg-[#ef4444]/15 text-[#f5f5f5]" : toast.type === "warning" ? "border-[#f59e0b]/30 bg-[#f59e0b]/15 text-[#f5f5f5]" : "border-[#2e2e2e] bg-[#242424] text-[#f5f5f5]"}`)}>${escape_html(toast.message)}</button>`);
		}
		$$renderer.push(`<!--]--></div>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
//#region src/routes/+layout.svelte
function _layout($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		Navbar($$renderer, {});
		$$renderer.push(`<!----> `);
		Toast($$renderer, {});
		$$renderer.push(`<!----> <main class="main page-fade"><!--[-->`);
		slot($$renderer, $$props, "default", {}, null);
		$$renderer.push(`<!--]--></main>`);
	});
}
//#endregion
export { _layout as default };
