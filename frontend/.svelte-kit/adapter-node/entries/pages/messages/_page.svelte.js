import { r as onDestroy } from "../../../chunks/index-server.js";
import { J as escape_html, K as attr, c as ensure_array_like, f as sanitize_props, g as unsubscribe_stores, h as store_get, l as head, m as spread_props, n as attr_class, p as slot } from "../../../chunks/dev.js";
import { l as authStore } from "../../../chunks/api.js";
import "../../../chunks/stores.js";
import { t as Icon } from "../../../chunks/Icon.js";
import { t as Plus } from "../../../chunks/plus.js";
import { t as Search } from "../../../chunks/search.js";
import { t as Send } from "../../../chunks/send.js";
import { a as formatDuration, s as videos, t as authors } from "../../../chunks/mockData.js";
import "phoenix";
//#region node_modules/lucide-svelte/dist/icons/check-check.svelte
function Check_check($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "check-check" },
		sanitize_props($$props),
		{
			/**
			* @component @name CheckCheck
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTggNiA3IDE3bC01LTUiIC8+CiAgPHBhdGggZD0ibTIyIDEwLTcuNSA3LjVMMTMgMTYiIC8+Cjwvc3ZnPgo=) - https://lucide.dev/icons/check-check
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M18 6 7 17l-5-5" }], ["path", { "d": "m22 10-7.5 7.5L13 16" }]],
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
//#region node_modules/lucide-svelte/dist/icons/ellipsis-vertical.svelte
function Ellipsis_vertical($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "ellipsis-vertical" },
		sanitize_props($$props),
		{
			/**
			* @component @name EllipsisVertical
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxIiAvPgogIDxjaXJjbGUgY3g9IjEyIiBjeT0iNSIgcj0iMSIgLz4KICA8Y2lyY2xlIGN4PSIxMiIgY3k9IjE5IiByPSIxIiAvPgo8L3N2Zz4K) - https://lucide.dev/icons/ellipsis-vertical
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [
				["circle", {
					"cx": "12",
					"cy": "12",
					"r": "1"
				}],
				["circle", {
					"cx": "12",
					"cy": "5",
					"r": "1"
				}],
				["circle", {
					"cx": "12",
					"cy": "19",
					"r": "1"
				}]
			],
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
//#region node_modules/lucide-svelte/dist/icons/paperclip.svelte
function Paperclip($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "paperclip" },
		sanitize_props($$props),
		{
			/**
			* @component @name Paperclip
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTMuMjM0IDIwLjI1MiAyMSAxMi4zIiAvPgogIDxwYXRoIGQ9Im0xNiA2LTguNDE0IDguNTg2YTIgMiAwIDAgMCAwIDIuODI4IDIgMiAwIDAgMCAyLjgyOCAwbDguNDE0LTguNTg2YTQgNCAwIDAgMCAwLTUuNjU2IDQgNCAwIDAgMC01LjY1NiAwbC04LjQxNSA4LjU4NWE2IDYgMCAxIDAgOC40ODYgOC40ODYiIC8+Cjwvc3ZnPgo=) - https://lucide.dev/icons/paperclip
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M13.234 20.252 21 12.3" }], ["path", { "d": "m16 6-8.414 8.586a2 2 0 0 0 0 2.828 2 2 0 0 0 2.828 0l8.414-8.586a4 4 0 0 0 0-5.656 4 4 0 0 0-5.656 0l-8.415 8.585a6 6 0 1 0 8.486 8.486" }]],
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
//#region node_modules/lucide-svelte/dist/icons/users.svelte
function Users($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "users" },
		sanitize_props($$props),
		{
			/**
			* @component @name Users
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTYgMjF2LTJhNCA0IDAgMCAwLTQtNEg2YTQgNCAwIDAgMC00IDR2MiIgLz4KICA8Y2lyY2xlIGN4PSI5IiBjeT0iNyIgcj0iNCIgLz4KICA8cGF0aCBkPSJNMjIgMjF2LTJhNCA0IDAgMCAwLTMtMy44NyIgLz4KICA8cGF0aCBkPSJNMTYgMy4xM2E0IDQgMCAwIDEgMCA3Ljc1IiAvPgo8L3N2Zz4K) - https://lucide.dev/icons/users
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [
				["path", { "d": "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" }],
				["circle", {
					"cx": "9",
					"cy": "7",
					"r": "4"
				}],
				["path", { "d": "M22 21v-2a4 4 0 0 0-3-3.87" }],
				["path", { "d": "M16 3.13a4 4 0 0 1 0 7.75" }]
			],
			children: ($$renderer) => {
				$$renderer.push(`<!--[-->`);
				slot($$renderer, $$props, "default", {}, null);
				$$renderer.push(`<!--]-->`);
			},
			$$slots: { default: true }
		}
	]));
}
/**
* @license lucide-svelte v0.468.0 - ISC
*
* This source code is licensed under the ISC license.
* See the LICENSE file in the root directory of this source tree.
*/
//#endregion
//#region src/routes/messages/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let currentUser, currentUserId, activeConversation, activeMessages, filteredConversations;
		const now = (/* @__PURE__ */ new Date()).toISOString();
		const currentUserFallback = {
			id: "me",
			username: "you",
			display_name: "Вы",
			avatar_url: "https://i.pravatar.cc/120?img=47"
		};
		let conversations = [
			{
				id: "local-1",
				type: "direct",
				name: "Арина Волкова",
				avatar_key: authors[0].avatar_url,
				unread_count: 2,
				last_message: {
					body: "Скинула тебе урок по Python, посмотри после обеда.",
					inserted_at: now,
					sender_id: authors[0].id
				},
				members: [{
					user_id: "me",
					user: currentUserFallback
				}, {
					user_id: authors[0].id,
					user: authors[0]
				}]
			},
			{
				id: "local-2",
				type: "group",
				name: "Backend Sprint",
				description: "Группа по проектам и разбору API",
				avatar_key: "https://picsum.photos/seed/learnflow-group/160/160",
				unread_count: 5,
				last_message: {
					body: "Завтра разбираем Phoenix Channels.",
					inserted_at: now,
					sender_id: authors[2].id
				},
				members: authors.slice(0, 4).map((user) => ({
					user_id: user.id,
					user
				}))
			},
			{
				id: "local-3",
				type: "direct",
				name: "Азамат Нуров",
				avatar_key: authors[1].avatar_url,
				unread_count: 0,
				last_message: {
					body: "Матрицы станут проще, обещаю.",
					inserted_at: now,
					sender_id: "me"
				},
				members: [{
					user_id: "me",
					user: currentUserFallback
				}, {
					user_id: authors[1].id,
					user: authors[1]
				}]
			}
		];
		let activeId = conversations[0].id;
		let messagesByConversation = {
			"local-1": [
				{
					id: "m1",
					sender_id: authors[0].id,
					sender: authors[0],
					body: "Привет! Нашла хороший короткий урок.",
					inserted_at: now,
					message_type: "text"
				},
				{
					id: "m2",
					sender_id: authors[0].id,
					sender: authors[0],
					body: "Скинула тебе урок по Python, посмотри после обеда.",
					inserted_at: now,
					message_type: "video_share",
					shared_video: videos[0]
				},
				{
					id: "m3",
					sender_id: "me",
					sender: currentUserFallback,
					body: "Класс, открою после созвона.",
					inserted_at: now,
					read_at: now,
					message_type: "text"
				}
			],
			"local-2": [{
				id: "m4",
				sender_id: authors[2].id,
				sender: authors[2],
				body: "Завтра разбираем Phoenix Channels.",
				inserted_at: now,
				message_type: "text"
			}, {
				id: "m5",
				sender_id: authors[3].id,
				sender: authors[3],
				body: "Я подготовлю вопросы по realtime.",
				inserted_at: now,
				message_type: "text"
			}],
			"local-3": [{
				id: "m6",
				sender_id: "me",
				sender: currentUserFallback,
				body: "Спасибо за разбор линейной алгебры.",
				inserted_at: now,
				read_at: now,
				message_type: "text"
			}, {
				id: "m7",
				sender_id: authors[1].id,
				sender: authors[1],
				body: "Матрицы станут проще, обещаю.",
				inserted_at: now,
				message_type: "text"
			}]
		};
		let query = "";
		let draft = "";
		onDestroy(() => void 0);
		function avatar(value) {
			return value?.avatar_url || value?.avatar_key || value || "https://i.pravatar.cc/120?img=47";
		}
		function preview(message) {
			if (!message) return "Новый чат";
			if (message.message_type === "video_share") return "Видео: " + (message.shared_video?.title || message.body || "урок");
			return message.body || "Сообщение";
		}
		function time(value) {
			if (!value) return "";
			return new Intl.DateTimeFormat("ru", {
				hour: "2-digit",
				minute: "2-digit"
			}).format(new Date(value));
		}
		$: currentUser = store_get($$store_subs ??= {}, "$authStore", authStore).user || currentUserFallback;
		$: currentUserId = currentUser.id || "me";
		$: activeConversation = conversations.find((item) => item.id === activeId) || conversations[0];
		$: activeMessages = messagesByConversation[activeId] || [];
		$: filteredConversations = conversations.filter((item) => item.name?.toLowerCase().includes(query.toLowerCase()));
		head("1iamj51", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Сообщения | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="messages-page svelte-1iamj51"><aside class="conversation-panel svelte-1iamj51"><header class="svelte-1iamj51"><h1 class="svelte-1iamj51">Сообщения</h1> <button class="icon-btn svelte-1iamj51" aria-label="Создать группу">`);
		Plus($$renderer, { size: 20 });
		$$renderer.push(`<!----></button></header> <label class="search-box svelte-1iamj51">`);
		Search($$renderer, { size: 18 });
		$$renderer.push(`<!----> <input${attr("value", query)} placeholder="Поиск чатов" class="svelte-1iamj51"/></label> <button class="group-btn svelte-1iamj51">`);
		Users($$renderer, { size: 18 });
		$$renderer.push(`<!----> Создать группу</button> <div class="conversation-list svelte-1iamj51"><!--[-->`);
		const each_array = ensure_array_like(filteredConversations);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let conversation = each_array[$$index];
			$$renderer.push(`<button${attr_class("conversation-row svelte-1iamj51", void 0, { "active": conversation.id === activeId })}><img${attr("src", avatar(conversation.avatar_key))} alt="" class="svelte-1iamj51"/> <span class="row-main svelte-1iamj51"><strong class="svelte-1iamj51">${escape_html(conversation.name)}</strong> <small class="svelte-1iamj51">${escape_html(preview(conversation.last_message))}</small></span> <span class="row-meta svelte-1iamj51"><small class="svelte-1iamj51">${escape_html(time(conversation.last_message?.inserted_at || conversation.updated_at))}</small> `);
			if (conversation.unread_count) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<b class="svelte-1iamj51">${escape_html(conversation.unread_count)}</b>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--></span></button>`);
		}
		$$renderer.push(`<!--]--></div></aside> <section class="chat-panel svelte-1iamj51"><header class="chat-head svelte-1iamj51"><img${attr("src", avatar(activeConversation?.avatar_key))} alt="" class="svelte-1iamj51"/> <div class="svelte-1iamj51"><strong class="svelte-1iamj51">${escape_html(activeConversation?.name)}</strong> <span class="svelte-1iamj51">${escape_html("online")}</span></div> <button class="icon-btn svelte-1iamj51" aria-label="Меню">`);
		Ellipsis_vertical($$renderer, { size: 20 });
		$$renderer.push(`<!----></button></header> <div class="messages-list svelte-1iamj51"><!--[-->`);
		const each_array_1 = ensure_array_like(activeMessages);
		for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
			let message = each_array_1[$$index_1];
			$$renderer.push(`<article${attr_class("svelte-1iamj51", void 0, { "own": message.sender_id === currentUserId })}>`);
			if (message.sender_id !== currentUserId) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<img${attr("src", avatar(message.sender))} alt="" class="svelte-1iamj51"/>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> <div class="bubble svelte-1iamj51">`);
			if (activeConversation?.type === "group" && message.sender_id !== currentUserId) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<strong class="sender-name svelte-1iamj51">${escape_html(message.sender?.display_name || message.sender?.username)}</strong>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			if (message.shared_video) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<a class="shared-video svelte-1iamj51"${attr("href", `/video/${message.shared_video.slug}`)}><img${attr("src", message.shared_video.thumbnail_url || message.shared_video.wide_thumbnail_url)} alt="" class="svelte-1iamj51"/> <span><strong class="svelte-1iamj51">${escape_html(message.shared_video.title)}</strong> <small class="svelte-1iamj51">${escape_html(formatDuration(message.shared_video.duration_seconds || 0))}</small></span></a>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			if (message.body) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<p class="svelte-1iamj51">${escape_html(message.body)}</p>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> <footer class="svelte-1iamj51"><time>${escape_html(time(message.inserted_at))}</time> `);
			if (message.sender_id === currentUserId) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<span${attr_class("svelte-1iamj51", void 0, { "read": message.read_at })}>`);
				Check_check($$renderer, { size: 14 });
				$$renderer.push(`<!----></span>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--></footer></div></article>`);
		}
		$$renderer.push(`<!--]--></div> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <form class="message-input svelte-1iamj51"><button type="button" class="icon-btn svelte-1iamj51" aria-label="Прикрепить">`);
		Paperclip($$renderer, { size: 21 });
		$$renderer.push(`<!----></button> <input${attr("value", draft)} placeholder="Написать сообщение..." class="svelte-1iamj51"/> <button class="send-btn svelte-1iamj51" type="submit">`);
		Send($$renderer, { size: 20 });
		$$renderer.push(`<!----></button></form></section> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
