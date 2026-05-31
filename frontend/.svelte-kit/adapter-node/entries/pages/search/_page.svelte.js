import "../../../chunks/index-server.js";
import { J as escape_html, K as attr, c as ensure_array_like, g as unsubscribe_stores, l as head, n as attr_class } from "../../../chunks/dev.js";
import "../../../chunks/stores.js";
import { t as Search } from "../../../chunks/search.js";
import { t as VideoCard } from "../../../chunks/VideoCard.js";
import { s as videos } from "../../../chunks/mockData.js";
//#region src/routes/search/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let results;
		let q = "";
		let category = "Все";
		const categories = [
			"Все",
			"Программирование",
			"Математика",
			"Дизайн",
			"Физика",
			"Языки",
			"Бизнес"
		];
		$: results = videos.filter((video) => {
			const query = q.trim().toLowerCase();
			return (!query || `${video.title} ${video.description} ${video.creator.display_name} ${video.creator.username}`.toLowerCase().includes(query)) && true;
		});
		head("e12qt1", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Поиск | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="search-page svelte-e12qt1"><label class="search-box svelte-e12qt1">`);
		Search($$renderer, { size: 22 });
		$$renderer.push(`<!----> <input${attr("value", q)} placeholder="Найди свой следующий урок..." class="svelte-e12qt1"/></label> <div class="categories svelte-e12qt1"><!--[-->`);
		const each_array = ensure_array_like(categories);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let item = each_array[$$index];
			$$renderer.push(`<button${attr_class("svelte-e12qt1", void 0, { "active": category === item })}>${escape_html(item)}</button>`);
		}
		$$renderer.push(`<!--]--></div> `);
		if (q.trim());
		else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<div class="explore svelte-e12qt1"><!--[-->`);
			const each_array_2 = ensure_array_like(results.slice(0, 15));
			for (let index = 0, $$length = each_array_2.length; index < $$length; index++) {
				let video = each_array_2[index];
				$$renderer.push(`<div${attr_class("svelte-e12qt1", void 0, { "large": index === 0 })}>`);
				VideoCard($$renderer, {
					video,
					aspect: "square"
				});
				$$renderer.push(`<!----></div>`);
			}
			$$renderer.push(`<!--]--></div>`);
		}
		$$renderer.push(`<!--]--></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
