import "../../../../chunks/index-server.js";
import { J as escape_html, K as attr, c as ensure_array_like, g as unsubscribe_stores, h as store_get, l as head, n as attr_class, r as attr_style } from "../../../../chunks/dev.js";
import "../../../../chunks/api.js";
import { t as page } from "../../../../chunks/stores.js";
import "../../../../chunks/navigation.js";
import { t as VideoCard } from "../../../../chunks/VideoCard.js";
import { r as findAuthor, s as videos } from "../../../../chunks/mockData.js";
//#region src/routes/profile/[username]/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let profileVideos;
		let profile = findAuthor(store_get($$store_subs ??= {}, "$page", page).params.username);
		let tab = "Видео";
		let followed = false;
		const tabs = [
			{
				icon: "🎬",
				label: "Видео"
			},
			{
				icon: "📚",
				label: "Курсы"
			},
			{
				icon: "❤️",
				label: "Лайки"
			}
		];
		$: profileVideos = videos.filter((video) => video.creator.username === profile.username);
		head("y31r23", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>${escape_html(profile.display_name)} | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="profile-page svelte-y31r23"><header class="profile-head svelte-y31r23"><img class="avatar svelte-y31r23"${attr("src", profile.avatar_url || "https://i.pravatar.cc/160?img=47")} alt=""/> <div class="identity svelte-y31r23"><div class="name-row svelte-y31r23"><div><h1 class="svelte-y31r23">@${escape_html(profile.username)}</h1> <p class="svelte-y31r23">${escape_html(profile.display_name)}</p></div> <div class="buttons svelte-y31r23"><button${attr_class("svelte-y31r23", void 0, { "followed": followed })}>${escape_html("Подписаться")}</button> <button class="svelte-y31r23">Написать</button></div></div> <div class="stats svelte-y31r23"><span class="svelte-y31r23"><strong class="svelte-y31r23">${escape_html(profile.videos_count || profileVideos.length)}</strong>Видео</span> <span class="svelte-y31r23"><strong class="svelte-y31r23">${escape_html(profile.followers_count || 0)}</strong>Подписчики</span> <span class="svelte-y31r23"><strong class="svelte-y31r23">${escape_html(profile.following_count || 0)}</strong>Подписки</span></div> <p class="bio svelte-y31r23">${escape_html(profile.bio)}</p> <div class="tags svelte-y31r23"><!--[-->`);
		const each_array = ensure_array_like(profile.tags || ["Python", "Дизайн"]);
		for (let index = 0, $$length = each_array.length; index < $$length; index++) {
			let tag = each_array[index];
			$$renderer.push(`<span${attr_style(`--tag:${[
				"#6366f1",
				"#a855f7",
				"#ec4899",
				"#16a34a"
			][index % 4]}`)} class="svelte-y31r23">${escape_html(tag)}</span>`);
		}
		$$renderer.push(`<!--]--></div></div></header> <nav class="tabs svelte-y31r23"><!--[-->`);
		const each_array_1 = ensure_array_like(tabs);
		for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
			let item = each_array_1[$$index_1];
			$$renderer.push(`<button${attr_class("svelte-y31r23", void 0, { "active": tab === item.label })}>${escape_html(item.icon)} ${escape_html(item.label)}</button>`);
		}
		$$renderer.push(`<!--]--></nav> <div class="grid svelte-y31r23"><!--[-->`);
		const each_array_2 = ensure_array_like(profileVideos.length ? profileVideos : videos.slice(0, 9));
		for (let $$index_2 = 0, $$length = each_array_2.length; $$index_2 < $$length; $$index_2++) {
			let video = each_array_2[$$index_2];
			VideoCard($$renderer, {
				video,
				aspect: "vertical"
			});
		}
		$$renderer.push(`<!--]--></div></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
