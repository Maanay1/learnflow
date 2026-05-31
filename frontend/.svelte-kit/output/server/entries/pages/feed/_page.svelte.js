import { m as head } from "../../../chunks/index-server.js";
import "../../../chunks/api.js";
import "../../../chunks/VideoCard.js";
//#region src/routes/feed/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		head("1ooj66h", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Лента | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="shell py-8"><header class="svelte-1ooj66h"><div><p class="svelte-1ooj66h">LearnFlow</p><h1 class="svelte-1ooj66h">Лента видео</h1></div><a href="/search" class="svelte-1ooj66h">Поиск</a></header> `);
		$$renderer.push("<!--[0-->");
		$$renderer.push(`<div class="state svelte-1ooj66h">Загружаем видео...</div>`);
		$$renderer.push(`<!--]--></section>`);
	});
}
//#endregion
export { _page as default };
