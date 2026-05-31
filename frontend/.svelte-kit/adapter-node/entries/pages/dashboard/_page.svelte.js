import "../../../chunks/index-server.js";
import { J as escape_html, c as ensure_array_like, g as unsubscribe_stores, h as store_get, n as attr_class, q as clsx, r as attr_style } from "../../../chunks/dev.js";
import { l as authStore } from "../../../chunks/api.js";
import { t as goto } from "../../../chunks/client.js";
import "../../../chunks/navigation.js";
import "../../../chunks/CourseCard.js";
import "../../../chunks/VideoCard.js";
//#region src/routes/dashboard/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let stats = {};
		let history = [];
		let activeTab = "overview";
		$: Math.max(1, ...[].map((point) => point.revenue_cents || 0));
		$: if (!store_get($$store_subs ??= {}, "$authStore", authStore).loading && !store_get($$store_subs ??= {}, "$authStore", authStore).authenticated) goto("/login");
		$$renderer.push(`<section class="shell space-y-8 py-8"><h1 class="text-3xl font-black">Dashboard</h1> <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4"><!--[-->`);
		const each_array = ensure_array_like([
			["Просмотрено", stats.total_watched],
			["Завершено", stats.total_completed],
			["Streak 🔥", stats.current_streak],
			["Подписчики", stats.followers_count]
		]);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let card = each_array[$$index];
			$$renderer.push(`<div class="card p-5"><p class="text-[#a3a3a3]">${escape_html(card[0])}</p><p class="mt-2 text-3xl font-black">${escape_html(card[1] || 0)}</p></div>`);
		}
		$$renderer.push(`<!--]--></div> <div class="flex flex-wrap gap-2"><!--[-->`);
		const each_array_1 = ensure_array_like([
			["overview", "Обзор"],
			["courses", "Мои курсы"],
			["saved", "Сохранённые"],
			...store_get($$store_subs ??= {}, "$authStore", authStore).user?.is_creator ? [["earnings", "Доходы"]] : []
		]);
		for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
			let tab = each_array_1[$$index_1];
			$$renderer.push(`<button${attr_class(clsx(activeTab === tab[0] ? "btn" : "btn-secondary"))}>${escape_html(tab[1])}</button>`);
		}
		$$renderer.push(`<!--]--></div> `);
		$$renderer.push("<!--[0-->");
		$$renderer.push(`<section><h2 class="mb-4 text-xl font-black">Продолжить просмотр</h2>`);
		if (history.length) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="space-y-3"><!--[-->`);
			const each_array_2 = ensure_array_like(history);
			for (let $$index_2 = 0, $$length = each_array_2.length; $$index_2 < $$length; $$index_2++) {
				let row = each_array_2[$$index_2];
				$$renderer.push(`<div class="card flex items-center gap-4 p-3"><div class="flex-1"><p class="font-bold">${escape_html(row.video?.title)}</p><div class="mt-2 h-2 rounded-full bg-[#242424]"><div class="progress-fill h-full rounded-full bg-primary"${attr_style(`width:${Math.min(100, (row.seconds_watched || 0) / (row.video?.duration_seconds || 1) * 100)}%`)}></div></div></div><button class="btn-secondary">Удалить</button></div>`);
			}
			$$renderer.push(`<!--]--></div>`);
		} else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<div class="card p-8 text-center text-[var(--text-2)]">Здесь будет история просмотров</div>`);
		}
		$$renderer.push(`<!--]--></section>`);
		$$renderer.push(`<!--]--></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
