import { $ as escape_html, Z as attr, c as attr_style, ot as fallback, u as bind_props } from "./index-server.js";
//#region src/lib/components/Avatar.svelte
function Avatar($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let name, initials, hue;
		let user = fallback($$props["user"], () => ({}), true);
		let size = fallback($$props["size"], 32);
		$: name = user?.display_name || user?.username || "LF";
		$: initials = name.split(/\s|_/).filter(Boolean).slice(0, 2).map((p) => p[0]).join("").toUpperCase();
		$: hue = [...user?.username || name].reduce((sum, ch) => sum + ch.charCodeAt(0), 0) % 360;
		if (user?.avatar_url || user?.avatar_key) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<img class="rounded-full object-cover"${attr_style(`width:${size}px;height:${size}px`)}${attr("src", user.avatar_url || `/media/${user.avatar_key}`)}${attr("alt", name)}/>`);
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
export { Avatar as t };
