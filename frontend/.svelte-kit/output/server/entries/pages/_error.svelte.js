import { $ as escape_html, b as store_get, x as unsubscribe_stores } from "../../chunks/index-server.js";
import { t as page } from "../../chunks/stores.js";
import "../../chunks/navigation.js";
//#region src/routes/+error.svelte
function _error($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let is404;
		let retry = 5;
		$: is404 = store_get($$store_subs ??= {}, "$page", page).status === 404;
		$$renderer.push(`<section class="shell grid min-h-[70vh] place-items-center py-12"><div class="card max-w-lg p-8 text-center"><h1 class="text-4xl font-black">${escape_html(is404 ? "Страница не найдена" : "Ошибка сети")}</h1> <p class="mt-3 text-[var(--text-2)]">${escape_html(is404 ? "Такой страницы нет или она была перемещена." : `Попробуйте обновить страницу. Повтор через ${retry} сек.`)}</p> <div class="mt-6 flex justify-center gap-3"><a class="btn" href="/">На главную</a> `);
		if (!is404) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<button class="btn-secondary">Повторить</button>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--></div></div></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _error as default };
