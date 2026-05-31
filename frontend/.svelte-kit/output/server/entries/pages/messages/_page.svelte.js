import { $ as escape_html, Z as attr, _ as sanitize_props, b as store_get, m as head, p as ensure_array_like, r as onDestroy, s as attr_class, v as slot, x as unsubscribe_stores, y as spread_props } from "../../../chunks/index-server.js";
import { d as authStore } from "../../../chunks/api.js";
import { t as goto } from "../../../chunks/client.js";
import "../../../chunks/stores.js";
import { t as Icon } from "../../../chunks/Icon.js";
import { t as Search } from "../../../chunks/search.js";
import { t as Avatar } from "../../../chunks/Avatar.js";
import "../../../chunks/navigation.js";
import "phoenix";
//#region node_modules/lucide-svelte/dist/icons/send.svelte
function Send($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "send" },
		sanitize_props($$props),
		{
			/**
			* @component @name Send
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTQuNTM2IDIxLjY4NmEuNS41IDAgMCAwIC45MzctLjAyNGw2LjUtMTlhLjQ5Ni40OTYgMCAwIDAtLjYzNS0uNjM1bC0xOSA2LjVhLjUuNSAwIDAgMC0uMDI0LjkzN2w3LjkzIDMuMThhMiAyIDAgMCAxIDEuMTEyIDEuMTF6IiAvPgogIDxwYXRoIGQ9Im0yMS44NTQgMi4xNDctMTAuOTQgMTAuOTM5IiAvPgo8L3N2Zz4K) - https://lucide.dev/icons/send
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M14.536 21.686a.5.5 0 0 0 .937-.024l6.5-19a.496.496 0 0 0-.635-.635l-19 6.5a.5.5 0 0 0-.024.937l7.93 3.18a2 2 0 0 1 1.112 1.11z" }], ["path", { "d": "m21.854 2.147-10.94 10.939" }]],
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
//#region src/routes/messages/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let currentUser, activeConversation, activeMessages;
		let conversations = [];
		let messagesByConversation = {};
		let activeId = "";
		let query = "";
		let draft = "";
		onDestroy(() => void 0);
		function conversationUser(conversation) {
			if (!conversation) return {};
			if (conversation.type === "group") return {
				display_name: conversation.name,
				avatar_key: conversation.avatar_key
			};
			return conversation.members?.find((member) => member.user_id !== currentUser?.id)?.user || { display_name: conversation.name };
		}
		const time = (value) => value ? new Intl.DateTimeFormat("ru", {
			hour: "2-digit",
			minute: "2-digit"
		}).format(new Date(value)) : "";
		$: currentUser = store_get($$store_subs ??= {}, "$authStore", authStore).user;
		$: activeConversation = conversations.find((item) => item.id === activeId);
		$: activeMessages = messagesByConversation[activeId] || [];
		$: conversations.filter((item) => item.name?.toLowerCase().includes(query.toLowerCase()));
		$: if (!store_get($$store_subs ??= {}, "$authStore", authStore).loading && !store_get($$store_subs ??= {}, "$authStore", authStore).authenticated) goto("/login");
		head("1iamj51", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Сообщения | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="page svelte-1iamj51"><aside class="svelte-1iamj51"><h1 class="svelte-1iamj51">Сообщения</h1> <label class="svelte-1iamj51">`);
		Search($$renderer, { size: 18 });
		$$renderer.push(`<!----><input${attr("value", query)} placeholder="Поиск чатов" class="svelte-1iamj51"/></label> `);
		$$renderer.push("<!--[0-->");
		$$renderer.push(`<p class="empty svelte-1iamj51">Загружаем...</p>`);
		$$renderer.push(`<!--]--></aside> <main class="svelte-1iamj51">`);
		if (activeConversation) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<header class="svelte-1iamj51">`);
			Avatar($$renderer, {
				user: conversationUser(activeConversation),
				size: 42
			});
			$$renderer.push(`<!----><strong>${escape_html(activeConversation.name)}</strong></header> <div class="list svelte-1iamj51">`);
			if (activeMessages.length) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<!--[-->`);
				const each_array_1 = ensure_array_like(activeMessages);
				for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
					let message = each_array_1[$$index_1];
					$$renderer.push(`<article${attr_class("svelte-1iamj51", void 0, { "own": message.sender_id === currentUser?.id })}>`);
					if (message.sender_id !== currentUser?.id) {
						$$renderer.push("<!--[0-->");
						Avatar($$renderer, {
							user: message.sender,
							size: 30
						});
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--><div class="svelte-1iamj51">`);
					if (message.shared_video) {
						$$renderer.push("<!--[0-->");
						$$renderer.push(`<a class="shared svelte-1iamj51"${attr("href", `/video/${message.shared_video.slug}`)}>${escape_html(message.shared_video.title)}</a>`);
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]-->`);
					if (message.body) {
						$$renderer.push("<!--[0-->");
						$$renderer.push(`<p>${escape_html(message.body)}</p>`);
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--><small class="svelte-1iamj51">${escape_html(time(message.inserted_at))}</small></div></article>`);
				}
				$$renderer.push(`<!--]-->`);
			} else {
				$$renderer.push("<!--[-1-->");
				$$renderer.push(`<p class="empty svelte-1iamj51">Нет сообщений</p>`);
			}
			$$renderer.push(`<!--]--></div> `);
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> <form class="svelte-1iamj51"><input${attr("value", draft)} placeholder="Написать сообщение..." class="svelte-1iamj51"/><button aria-label="Отправить" class="svelte-1iamj51">`);
			Send($$renderer, { size: 20 });
			$$renderer.push(`<!----></button></form>`);
		} else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<div class="empty center svelte-1iamj51">Выбери чат, чтобы начать общение</div>`);
		}
		$$renderer.push(`<!--]--></main></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
