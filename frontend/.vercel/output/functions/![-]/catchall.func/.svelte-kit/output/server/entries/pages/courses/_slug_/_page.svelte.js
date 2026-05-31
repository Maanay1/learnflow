import { $ as escape_html, Z as attr, x as unsubscribe_stores } from "../../../../chunks/index-server.js";
import "../../../../chunks/api.js";
import "../../../../chunks/stores.js";
import "../../../../chunks/Avatar.js";
import "../../../../chunks/TagPill.js";
import { t as Modal } from "../../../../chunks/Modal.js";
//#region src/routes/courses/[slug]/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let course;
		let payOpen = false;
		let paying = false;
		const money = (cents = 0) => `${Math.round(cents / 100)}₽`;
		$: "".split(/[.\n]/).map((x) => x.trim()).filter(Boolean).slice(0, 5);
		$$renderer.push(`<section class="shell py-8">`);
		$$renderer.push("<!--[0-->");
		$$renderer.push(`<div class="skeleton h-96 rounded-xl"></div>`);
		$$renderer.push(`<!--]--></section> `);
		if (payOpen) {
			$$renderer.push("<!--[0-->");
			Modal($$renderer, {
				open: true,
				title: "Оплата курса",
				onClose: () => payOpen = false,
				children: ($$renderer) => {
					$$renderer.push(`<div class="space-y-4"><p class="text-[var(--text-2)]">${escape_html(course.title)}</p> <p class="text-3xl font-black">${escape_html(money(course.price_cents))}</p> <div id="stripe-card" class="rounded-lg border border-[var(--border)] bg-[var(--surface-2)] p-4"></div> <button class="btn w-full"${attr("disabled", paying, true)}>${escape_html("Оплатить")}</button></div>`);
				},
				$$slots: { default: true }
			});
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]-->`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
