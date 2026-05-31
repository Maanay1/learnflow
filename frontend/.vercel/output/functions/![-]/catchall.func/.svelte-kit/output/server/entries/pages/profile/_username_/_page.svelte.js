import { $ as escape_html, m as head, x as unsubscribe_stores } from "../../../../chunks/index-server.js";
import "../../../../chunks/api.js";
import "../../../../chunks/stores.js";
import "../../../../chunks/Avatar.js";
import "../../../../chunks/navigation.js";
import "../../../../chunks/VideoCard.js";
//#region src/routes/profile/[username]/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		head("y31r23", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>${escape_html("Профиль")} | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="shell max-w-5xl py-8">`);
		$$renderer.push("<!--[0-->");
		$$renderer.push(`<p class="empty svelte-y31r23">Загружаем профиль...</p>`);
		$$renderer.push(`<!--]--></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
