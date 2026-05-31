import { $ as escape_html, ot as fallback, u as bind_props, v as slot } from "./index-server.js";
//#region src/lib/components/Modal.svelte
function Modal($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let open = fallback($$props["open"], false);
		let title = fallback($$props["title"], "");
		let onClose = fallback($$props["onClose"], () => {});
		if (open) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="fixed inset-0 z-50 grid place-items-center bg-black/70 p-4" role="button" tabindex="0"><section class="w-full max-w-lg rounded-xl border border-[#2e2e2e] bg-[#1a1a1a] p-5" role="dialog" aria-modal="true" tabindex="-1"><div class="mb-4 flex items-center justify-between"><h2 class="text-xl font-bold">${escape_html(title)}</h2> <button class="btn-secondary px-3">×</button></div> <!--[-->`);
			slot($$renderer, $$props, "default", {}, null);
			$$renderer.push(`<!--]--></section></div>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]-->`);
		bind_props($$props, {
			open,
			title,
			onClose
		});
	});
}
//#endregion
export { Modal as t };
