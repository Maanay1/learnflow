import { $ as escape_html, c as attr_style, ot as fallback, s as attr_class, u as bind_props } from "./index-server.js";
//#region src/lib/components/DifficultyBadge.svelte
function DifficultyBadge($$renderer, $$props) {
	let difficulty = fallback($$props["difficulty"], "beginner");
	const labels = {
		beginner: "Beginner",
		intermediate: "Intermediate",
		advanced: "Advanced"
	};
	const styles = {
		beginner: "bg-[#22c55e]/15 text-[#22c55e]",
		intermediate: "bg-[#f59e0b]/15 text-[#f59e0b]",
		advanced: "bg-[#ef4444]/15 text-[#ef4444]"
	};
	$$renderer.push(`<span${attr_class(`inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ${styles[difficulty] || styles.beginner}`)}>${escape_html(labels[difficulty] || difficulty)}</span>`);
	bind_props($$props, { difficulty });
}
//#endregion
//#region src/lib/components/TagPill.svelte
function TagPill($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let tag = fallback($$props["tag"], () => ({
			name: "General",
			color: "#6366f1"
		}), true);
		$$renderer.push(`<span class="inline-flex rounded-full px-2.5 py-1 text-xs font-semibold text-white"${attr_style(`background:${tag.color || "#6366f1"}33;color:${tag.color || "#6366f1"}`)}>${escape_html(tag.name)}</span>`);
		bind_props($$props, { tag });
	});
}
//#endregion
export { DifficultyBadge as n, TagPill as t };
