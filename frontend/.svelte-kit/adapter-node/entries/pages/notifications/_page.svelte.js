import { J as escape_html, K as attr, c as ensure_array_like, l as head, n as attr_class, r as attr_style } from "../../../chunks/dev.js";
import { o as notifications } from "../../../chunks/mockData.js";
//#region src/routes/notifications/+page.svelte
function _page($$renderer) {
	head("1ce0uvz", $$renderer, ($$renderer) => {
		$$renderer.title(($$renderer) => {
			$$renderer.push(`<title>Уведомления | LearnFlow</title>`);
		});
	});
	$$renderer.push(`<section class="notifications-page svelte-1ce0uvz"><h1 class="svelte-1ce0uvz">Уведомления</h1> <!--[-->`);
	const each_array = ensure_array_like(notifications);
	for (let $$index_1 = 0, $$length = each_array.length; $$index_1 < $$length; $$index_1++) {
		let group = each_array[$$index_1];
		$$renderer.push(`<section class="group svelte-1ce0uvz"><h2 class="svelte-1ce0uvz">${escape_html(group[0])}</h2> <div><!--[-->`);
		const each_array_1 = ensure_array_like(group[1]);
		for (let index = 0, $$length = each_array_1.length; index < $$length; index++) {
			let item = each_array_1[index];
			$$renderer.push(`<article${attr_style(`animation-delay:${index * 45}ms`)}${attr_class("svelte-1ce0uvz", void 0, { "unread": item.unread })}><img class="avatar svelte-1ce0uvz"${attr("src", item.avatar)} alt=""/> <p class="svelte-1ce0uvz">${escape_html(item.text)}<span class="svelte-1ce0uvz">${escape_html(item.time)}</span></p> `);
			if (item.thumbnail) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<img class="thumb svelte-1ce0uvz"${attr("src", item.thumbnail)} alt=""/>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--></article>`);
		}
		$$renderer.push(`<!--]--></div></section>`);
	}
	$$renderer.push(`<!--]--></section>`);
}
//#endregion
export { _page as default };
