import { Z as attr, m as head, p as ensure_array_like, x as unsubscribe_stores } from "../../../chunks/index-server.js";
import { i as feed } from "../../../chunks/api.js";
import "../../../chunks/stores.js";
import { t as Search } from "../../../chunks/search.js";
import { t as VideoCard } from "../../../chunks/VideoCard.js";
//#region src/routes/search/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let q = "";
		let results = [];
		let loading = true;
		let timer;
		async function load() {
			loading = true;
			try {
				results = (q.trim(), (await feed.list({ limit: 20 })).items || []);
			} catch {
				results = [];
			} finally {
				loading = false;
			}
		}
		$: {
			clearTimeout(timer);
			timer = setTimeout(load, 250);
		}
		head("e12qt1", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Поиск | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="shell py-8"><label class="svelte-e12qt1">`);
		Search($$renderer, { size: 20 });
		$$renderer.push(`<!----><input${attr("value", q)} placeholder="Найди свой следующий урок..." class="svelte-e12qt1"/></label> `);
		if (loading) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<p class="empty svelte-e12qt1">Поиск...</p>`);
		} else if (results.length) {
			$$renderer.push("<!--[1-->");
			$$renderer.push(`<div class="grid svelte-e12qt1"><!--[-->`);
			const each_array = ensure_array_like(results);
			for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
				let video = each_array[$$index];
				VideoCard($$renderer, {
					video,
					aspect: "square"
				});
			}
			$$renderer.push(`<!--]--></div>`);
		} else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<p class="empty svelte-e12qt1">Ничего не найдено</p>`);
		}
		$$renderer.push(`<!--]--></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
