import { $ as escape_html, m as head, x as unsubscribe_stores } from "../../../../chunks/index-server.js";
import "../../../../chunks/api.js";
import "../../../../chunks/stores.js";
import "../../../../chunks/Icon.js";
import "../../../../chunks/messages-square.js";
import "../../../../chunks/Avatar.js";
import "../../../../chunks/navigation.js";
/**
* @license lucide-svelte v0.468.0 - ISC
*
* This source code is licensed under the ISC license.
* See the LICENSE file in the root directory of this source tree.
*/
/**
* @license lucide-svelte v0.468.0 - ISC
*
* This source code is licensed under the ISC license.
* See the LICENSE file in the root directory of this source tree.
*/
/**
* @license lucide-svelte v0.468.0 - ISC
*
* This source code is licensed under the ISC license.
* See the LICENSE file in the root directory of this source tree.
*/
/**
* @license lucide-svelte v0.468.0 - ISC
*
* This source code is licensed under the ISC license.
* See the LICENSE file in the root directory of this source tree.
*/
/**
* @license lucide-svelte v0.468.0 - ISC
*
* This source code is licensed under the ISC license.
* See the LICENSE file in the root directory of this source tree.
*/
//#endregion
//#region src/routes/video/[slug]/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		head("l5tz0a", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>${escape_html("Видео")} | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="shell max-w-5xl py-6">`);
		$$renderer.push("<!--[0-->");
		$$renderer.push(`<p class="empty svelte-l5tz0a">Загружаем видео...</p>`);
		$$renderer.push(`<!--]--></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
