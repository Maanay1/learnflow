import { m as head } from "../../../chunks/index-server.js";
import "../../../chunks/api.js";
import "../../../chunks/Avatar.js";
//#region src/routes/notifications/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		head("1ce0uvz", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Уведомления | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="shell max-w-3xl py-8"><h1 class="svelte-1ce0uvz">Уведомления</h1> `);
		$$renderer.push("<!--[0-->");
		$$renderer.push(`<p class="empty svelte-1ce0uvz">Загружаем...</p>`);
		$$renderer.push(`<!--]--></section>`);
	});
}
//#endregion
export { _page as default };
