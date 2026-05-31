import { t as createEventDispatcher } from "../../../../chunks/index-server.js";
import { J as escape_html, K as attr, a as bind_props, c as ensure_array_like, f as sanitize_props, g as unsubscribe_stores, h as store_get, l as head, m as spread_props, n as attr_class, p as slot, r as attr_style, rt as fallback } from "../../../../chunks/dev.js";
import "../../../../chunks/api.js";
import { t as page } from "../../../../chunks/stores.js";
import { t as Icon } from "../../../../chunks/Icon.js";
import { n as Heart, r as Bookmark, t as Play } from "../../../../chunks/play.js";
import { t as Messages_square } from "../../../../chunks/messages-square.js";
import "../../../../chunks/navigation.js";
import { i as findVideo, n as comments } from "../../../../chunks/mockData.js";
//#region node_modules/lucide-svelte/dist/icons/circle-check.svelte
function Circle_check($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "circle-check" },
		sanitize_props($$props),
		{
			/**
			* @component @name CircleCheck
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIgLz4KICA8cGF0aCBkPSJtOSAxMiAyIDIgNC00IiAvPgo8L3N2Zz4K) - https://lucide.dev/icons/circle-check
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["circle", {
				"cx": "12",
				"cy": "12",
				"r": "10"
			}], ["path", { "d": "m9 12 2 2 4-4" }]],
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
//#region node_modules/lucide-svelte/dist/icons/maximize.svelte
function Maximize($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "maximize" },
		sanitize_props($$props),
		{
			/**
			* @component @name Maximize
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNOCAzSDVhMiAyIDAgMCAwLTIgMnYzIiAvPgogIDxwYXRoIGQ9Ik0yMSA4VjVhMiAyIDAgMCAwLTItMmgtMyIgLz4KICA8cGF0aCBkPSJNMyAxNnYzYTIgMiAwIDAgMCAyIDJoMyIgLz4KICA8cGF0aCBkPSJNMTYgMjFoM2EyIDIgMCAwIDAgMi0ydi0zIiAvPgo8L3N2Zz4K) - https://lucide.dev/icons/maximize
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [
				["path", { "d": "M8 3H5a2 2 0 0 0-2 2v3" }],
				["path", { "d": "M21 8V5a2 2 0 0 0-2-2h-3" }],
				["path", { "d": "M3 16v3a2 2 0 0 0 2 2h3" }],
				["path", { "d": "M16 21h3a2 2 0 0 0 2-2v-3" }]
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
//#region node_modules/lucide-svelte/dist/icons/share-2.svelte
function Share_2($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "share-2" },
		sanitize_props($$props),
		{
			/**
			* @component @name Share2
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8Y2lyY2xlIGN4PSIxOCIgY3k9IjUiIHI9IjMiIC8+CiAgPGNpcmNsZSBjeD0iNiIgY3k9IjEyIiByPSIzIiAvPgogIDxjaXJjbGUgY3g9IjE4IiBjeT0iMTkiIHI9IjMiIC8+CiAgPGxpbmUgeDE9IjguNTkiIHgyPSIxNS40MiIgeTE9IjEzLjUxIiB5Mj0iMTcuNDkiIC8+CiAgPGxpbmUgeDE9IjE1LjQxIiB4Mj0iOC41OSIgeTE9IjYuNTEiIHkyPSIxMC40OSIgLz4KPC9zdmc+Cg==) - https://lucide.dev/icons/share-2
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [
				["circle", {
					"cx": "18",
					"cy": "5",
					"r": "3"
				}],
				["circle", {
					"cx": "6",
					"cy": "12",
					"r": "3"
				}],
				["circle", {
					"cx": "18",
					"cy": "19",
					"r": "3"
				}],
				["line", {
					"x1": "8.59",
					"x2": "15.42",
					"y1": "13.51",
					"y2": "17.49"
				}],
				["line", {
					"x1": "15.41",
					"x2": "8.59",
					"y1": "6.51",
					"y2": "10.49"
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
//#region node_modules/lucide-svelte/dist/icons/volume-2.svelte
function Volume_2($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "volume-2" },
		sanitize_props($$props),
		{
			/**
			* @component @name Volume2
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTEgNC43MDJhLjcwNS43MDUgMCAwIDAtMS4yMDMtLjQ5OEw2LjQxMyA3LjU4N0ExLjQgMS40IDAgMCAxIDUuNDE2IDhIM2ExIDEgMCAwIDAtMSAxdjZhMSAxIDAgMCAwIDEgMWgyLjQxNmExLjQgMS40IDAgMCAxIC45OTcuNDEzbDMuMzgzIDMuMzg0QS43MDUuNzA1IDAgMCAwIDExIDE5LjI5OHoiIC8+CiAgPHBhdGggZD0iTTE2IDlhNSA1IDAgMCAxIDAgNiIgLz4KICA8cGF0aCBkPSJNMTkuMzY0IDE4LjM2NGE5IDkgMCAwIDAgMC0xMi43MjgiIC8+Cjwvc3ZnPgo=) - https://lucide.dev/icons/volume-2
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [
				["path", { "d": "M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z" }],
				["path", { "d": "M16 9a5 5 0 0 1 0 6" }],
				["path", { "d": "M19.364 18.364a9 9 0 0 0 0-12.728" }]
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
//#region src/lib/components/VideoPlayer.svelte
function VideoPlayer($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let sourceKey, pct;
		let video = $$props["video"];
		let videoId = $$props["videoId"];
		let videoKey = fallback($$props["videoKey"], "");
		let videoUrl = fallback($$props["videoUrl"], "");
		let chapters = fallback($$props["chapters"], () => [], true);
		let initialProgress = fallback($$props["initialProgress"], 0);
		let resolvedUrl = "";
		let current = 0;
		let duration = 0;
		let volume = .9;
		createEventDispatcher();
		$: sourceKey = videoKey || video?.video_key || video?.view_url || videoUrl || "";
		$: pct = 0;
		$: if (sourceKey?.startsWith?.("http") && resolvedUrl !== sourceKey) resolvedUrl = sourceKey;
		$$renderer.push(`<section class="player-shell svelte-l6y7q"><video${attr("src", resolvedUrl)} class="video-el svelte-l6y7q" preload="metadata" playsinline=""><track kind="captions"/></video> `);
		$$renderer.push("<!--[0-->");
		$$renderer.push(`<button class="big-play svelte-l6y7q" aria-label="Play video">`);
		Play($$renderer, {
			size: 54,
			fill: "currentColor"
		});
		$$renderer.push(`<!----></button>`);
		$$renderer.push(`<!--]--> <div class="controls svelte-l6y7q"><div class="seek svelte-l6y7q"><span${attr_style(`width:${pct}%`)} class="svelte-l6y7q"></span> <input aria-label="Seek video" type="range" min="0"${attr("max", 0)}${attr("value", current)} class="svelte-l6y7q"/> <!--[-->`);
		const each_array = ensure_array_like(chapters || []);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			each_array[$$index];
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]-->`);
		}
		$$renderer.push(`<!--]--></div> <div class="control-row svelte-l6y7q"><button aria-label="Play pause" class="svelte-l6y7q">`);
		$$renderer.push("<!--[0-->");
		Play($$renderer, {
			size: 18,
			fill: "currentColor"
		});
		$$renderer.push(`<!--]--></button> <span>${escape_html(Math.floor(current / 60))}:${escape_html(String(Math.floor(current % 60)).padStart(2, "0"))} / ${escape_html(Math.floor(duration / 60))}:${escape_html(String(Math.floor(duration % 60)).padStart(2, "0"))}</span> <button class="svelte-l6y7q">${escape_html(1)}x</button> <label class="svelte-l6y7q">`);
		Volume_2($$renderer, { size: 18 });
		$$renderer.push(`<!----> <input type="range" min="0" max="1" step="0.05"${attr("value", volume)} class="svelte-l6y7q"/></label> <button aria-label="Fullscreen" class="svelte-l6y7q">`);
		Maximize($$renderer, { size: 18 });
		$$renderer.push(`<!----></button></div></div></section>`);
		bind_props($$props, {
			video,
			videoId,
			videoKey,
			videoUrl,
			chapters,
			initialProgress
		});
	});
}
//#endregion
//#region src/routes/video/[slug]/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let likeCount;
		let video = findVideo(store_get($$store_subs ??= {}, "$page", page).params.slug);
		let liked = false;
		let saved = false;
		let subscribed = false;
		let showReplies = {};
		let commentText = "";
		let commentList = comments;
		$: likeCount = (Number(video.like_count) || 0) + 0;
		head("l5tz0a", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>${escape_html(video.title)} | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="watch-page svelte-l5tz0a">`);
		VideoPlayer($$renderer, {
			video,
			videoId: video.id,
			videoKey: video.video_key || video.view_url,
			chapters: video.chapters || [],
			initialProgress: 0
		});
		$$renderer.push(`<!----> <article class="details svelte-l5tz0a"><h1 class="svelte-l5tz0a">${escape_html(video.title)}</h1> <div class="creator-line svelte-l5tz0a"><img${attr("src", video.creator?.avatar_url || "https://i.pravatar.cc/120?img=47")} alt="" class="svelte-l5tz0a"/> <div class="svelte-l5tz0a"><strong>${escape_html(video.creator?.display_name || video.creator?.username)}</strong> <span class="svelte-l5tz0a">@${escape_html(video.creator?.username)}</span></div> <button${attr_class("svelte-l5tz0a", void 0, { "subscribed": subscribed })}>${escape_html("Подписаться")}</button></div> <div class="chips svelte-l5tz0a"><span${attr_class(`difficulty ${video.difficulty}`, "svelte-l5tz0a")}>${escape_html(video.difficulty)}</span> <!--[-->`);
		const each_array = ensure_array_like(video.tags || []);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let tag = each_array[$$index];
			$$renderer.push(`<span${attr_style(`--tag:${tag.color || "#6366f1"}`)} class="svelte-l5tz0a">${escape_html(tag.name)}</span>`);
		}
		$$renderer.push(`<!--]--></div> <div class="description svelte-l5tz0a"><p${attr_class("svelte-l5tz0a", void 0, { "clamped": true })}>${escape_html(video.description)} В уроке есть быстрый разбор, практический пример и чеклист для повторения после просмотра.</p> <button class="svelte-l5tz0a">${escape_html("Показать описание")}</button></div> <div class="lesson-progress svelte-l5tz0a"><div class="svelte-l5tz0a"><strong>Просмотрено ${escape_html(video.progress || 0)}%</strong><span class="svelte-l5tz0a">Продолжайте с последней главы</span></div> <div class="svelte-l5tz0a"><span${attr_style(`width:${video.progress || 0}%`)} class="svelte-l5tz0a"></span></div></div> <div class="action-row svelte-l5tz0a"><button${attr_class("svelte-l5tz0a", void 0, {
			"liked": liked,
			"like-pulse": liked
		})}>`);
		Heart($$renderer, {
			size: 20,
			fill: "none"
		});
		$$renderer.push(`<!----> Нравится ${escape_html(likeCount)}</button> <button${attr_class("svelte-l5tz0a", void 0, { "saved": saved })}>`);
		Bookmark($$renderer, {
			size: 20,
			fill: "none"
		});
		$$renderer.push(`<!----> Сохранить</button> <button class="svelte-l5tz0a">`);
		Share_2($$renderer, { size: 20 });
		$$renderer.push(`<!----> Поделиться</button> <button class="svelte-l5tz0a">`);
		Messages_square($$renderer, { size: 20 });
		$$renderer.push(`<!----> В чат</button> <button class="complete svelte-l5tz0a">`);
		Circle_check($$renderer, { size: 20 });
		$$renderer.push(`<!----> Завершить урок</button></div></article> <section class="comments svelte-l5tz0a"><h2 class="svelte-l5tz0a">Комментарии (${escape_html(commentList.length)})</h2> <div class="comment-box svelte-l5tz0a"><img src="https://i.pravatar.cc/80?img=47" alt="" class="svelte-l5tz0a"/> <input${attr("value", commentText)} placeholder="Добавить комментарий..." class="svelte-l5tz0a"/> <button class="svelte-l5tz0a">Отправить</button></div> <!--[-->`);
		const each_array_1 = ensure_array_like(commentList);
		for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
			let comment = each_array_1[$$index_1];
			$$renderer.push(`<article class="svelte-l5tz0a"><img${attr("src", comment.user?.avatar_url || "https://i.pravatar.cc/80?img=47")} alt="" class="svelte-l5tz0a"/> <div class="svelte-l5tz0a"><header class="svelte-l5tz0a"><strong>${escape_html(comment.user?.display_name || comment.user?.username || "LearnFlow")}</strong><span class="svelte-l5tz0a">${escape_html(comment.ago || "сейчас")}</span></header> <p class="svelte-l5tz0a">${escape_html(comment.body)}</p> <button class="comment-like svelte-l5tz0a">♥ ${escape_html(comment.likes || 0)}</button> `);
			if (comment.replies?.length || comment.replies) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<button class="reply-toggle svelte-l5tz0a">${escape_html(showReplies[comment.id] ? "Скрыть ответы" : `Показать ответы (${Array.isArray(comment.replies) ? comment.replies.length : comment.replies})`)}</button> `);
				if (showReplies[comment.id]) {
					$$renderer.push("<!--[0-->");
					$$renderer.push(`<div class="reply svelte-l5tz0a">Спасибо! Уже готовим продолжение с задачами.</div>`);
				} else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]-->`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--></div></article>`);
		}
		$$renderer.push(`<!--]--></section></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
