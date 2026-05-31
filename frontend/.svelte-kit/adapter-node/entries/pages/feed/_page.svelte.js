import "../../../chunks/index-server.js";
import { J as escape_html, K as attr, c as ensure_array_like, f as sanitize_props, l as head, m as spread_props, n as attr_class, p as slot, r as attr_style } from "../../../chunks/dev.js";
import "../../../chunks/api.js";
import { t as Icon } from "../../../chunks/Icon.js";
import { n as Heart, r as Bookmark, t as Play } from "../../../chunks/play.js";
import { t as Plus } from "../../../chunks/plus.js";
import { t as Search } from "../../../chunks/search.js";
import { t as Send } from "../../../chunks/send.js";
import { a as formatDuration, s as videos } from "../../../chunks/mockData.js";
//#region node_modules/lucide-svelte/dist/icons/message-circle.svelte
function Message_circle($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "message-circle" },
		sanitize_props($$props),
		{
			/**
			* @component @name MessageCircle
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNNy45IDIwQTkgOSAwIDEgMCA0IDE2LjFMMiAyMloiIC8+Cjwvc3ZnPgo=) - https://lucide.dev/icons/message-circle
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M7.9 20A9 9 0 1 0 4 16.1L2 22Z" }]],
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
//#region src/routes/feed/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let visibleItems;
		let tab = "Для вас";
		let items = videos;
		let paused = {};
		let liked = {};
		let saved = {};
		let following = {};
		$: visibleItems = items.filter((video) => {
			return true;
		});
		head("1ooj66h", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Лента | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="feed-shell svelte-1ooj66h"><header class="feed-tabs svelte-1ooj66h"><div class="svelte-1ooj66h"><!--[-->`);
		const each_array = ensure_array_like([
			"Для вас",
			"Подписки",
			"Популярное"
		]);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let item = each_array[$$index];
			$$renderer.push(`<button${attr_class("svelte-1ooj66h", void 0, { "active": tab === item })}>${escape_html(item)}</button>`);
		}
		$$renderer.push(`<!--]--></div> <a href="/search" aria-label="Поиск" class="svelte-1ooj66h">`);
		Search($$renderer, { size: 24 });
		$$renderer.push(`<!----></a></header> <div class="snap-feed svelte-1ooj66h"><!--[-->`);
		const each_array_1 = ensure_array_like(visibleItems);
		for (let index = 0, $$length = each_array_1.length; index < $$length; index++) {
			let video = each_array_1[index];
			$$renderer.push(`<article class="reel svelte-1ooj66h"${attr_style(`--thumb:url('${video.thumbnail_url || video.wide_thumbnail_url}')`)}><img class="reel-bg svelte-1ooj66h"${attr("src", video.thumbnail_url || video.wide_thumbnail_url)} alt=""/> <div class="reel-blur svelte-1ooj66h"></div> <button class="reel-media svelte-1ooj66h" aria-label="Play pause"><img${attr("src", video.thumbnail_url || video.wide_thumbnail_url)}${attr("alt", video.title)} class="svelte-1ooj66h"/> `);
			if (paused[video.id] || index === 0) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<span class="play-button svelte-1ooj66h">`);
				Play($$renderer, {
					size: 46,
					fill: "currentColor"
				});
				$$renderer.push(`<!----></span>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--></button> <div class="top-badges svelte-1ooj66h"><span${attr_class(`difficulty ${video.difficulty}`, "svelte-1ooj66h")}>${escape_html(video.difficulty || "beginner")}</span> <span class="svelte-1ooj66h">${escape_html(formatDuration(video.duration_seconds))}</span></div> <aside class="actions svelte-1ooj66h"><button aria-label="Лайк"${attr_class("svelte-1ooj66h", void 0, {
				"liked": liked[video.id],
				"like-pulse": liked[video.id]
			})}>`);
			Heart($$renderer, {
				size: 29,
				fill: liked[video.id] ? "currentColor" : "none"
			});
			$$renderer.push(`<!----></button> <small class="svelte-1ooj66h">${escape_html((video.like_count || 34) + (liked[video.id] ? 1 : 0))}</small> <button aria-label="Комментарии" class="svelte-1ooj66h">`);
			Message_circle($$renderer, { size: 29 });
			$$renderer.push(`<!----></button> <small class="svelte-1ooj66h">${escape_html(video.comment_count || 12)}</small> <button aria-label="Сохранить"${attr_class("svelte-1ooj66h", void 0, { "saved": saved[video.id] })}>`);
			Bookmark($$renderer, {
				size: 29,
				fill: saved[video.id] ? "currentColor" : "none"
			});
			$$renderer.push(`<!----></button> <button aria-label="Поделиться" class="svelte-1ooj66h">`);
			Send($$renderer, { size: 28 });
			$$renderer.push(`<!----></button> <div class="follow-disc svelte-1ooj66h"><img${attr("src", video.creator?.avatar_url || "https://i.pravatar.cc/120?img=47")} alt="" class="svelte-1ooj66h"/> <button aria-label="Подписаться"${attr_class("svelte-1ooj66h", void 0, { "done": following[video.creator?.id] })}>`);
			Plus($$renderer, { size: 15 });
			$$renderer.push(`<!----></button></div></aside> <div class="reel-info svelte-1ooj66h"><div class="author svelte-1ooj66h"><img${attr("src", video.creator?.avatar_url || "https://i.pravatar.cc/120?img=47")} alt="" class="svelte-1ooj66h"/> <strong class="svelte-1ooj66h">${escape_html(video.creator?.display_name || video.creator?.username)}</strong></div> <a${attr("href", `/video/${video.slug}`)}><h2 class="svelte-1ooj66h">${escape_html(video.title)}</h2></a> <p class="svelte-1ooj66h">${escape_html(video.description)}</p> <span class="tag svelte-1ooj66h"${attr_style(`--tag:${video.tags?.[0]?.color || "#6366f1"}`)}>${escape_html(video.tags?.[0]?.name || "LearnFlow")}</span></div> <div class="progress svelte-1ooj66h"><span${attr_style(`width:${video.progress || 42}%`)} class="svelte-1ooj66h"></span></div></article>`);
		}
		$$renderer.push(`<!--]--></div></section> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]-->`);
	});
}
//#endregion
export { _page as default };
