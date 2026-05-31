import { J as escape_html, K as attr, a as bind_props, n as attr_class, r as attr_style, rt as fallback } from "./dev.js";
//#region src/lib/components/Avatar.svelte
function Avatar($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let name, initials, hue;
		let user = fallback($$props["user"], () => ({}), true);
		let size = fallback($$props["size"], 32);
		$: name = user?.display_name || user?.username || "LF";
		$: initials = name.split(/\s|_/).filter(Boolean).slice(0, 2).map((p) => p[0]).join("").toUpperCase();
		$: hue = [...user?.username || name].reduce((sum, ch) => sum + ch.charCodeAt(0), 0) % 360;
		if (user?.avatar_key) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<img class="rounded-full object-cover"${attr_style(`width:${size}px;height:${size}px`)}${attr("src", `/media/${user.avatar_key}`)}${attr("alt", name)}/>`);
		} else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<div class="grid rounded-full font-bold text-white"${attr_style(`width:${size}px;height:${size}px;place-items:center;background:hsl(${hue} 60% 42%)`)}><span${attr_style(`font-size:${Math.max(11, size * .36)}px`)}>${escape_html(initials)}</span></div>`);
		}
		$$renderer.push(`<!--]-->`);
		bind_props($$props, {
			user,
			size
		});
	});
}
//#endregion
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
export { DifficultyBadge as n, Avatar as r, TagPill as t };
