import { $ as escape_html, Z as attr, ot as fallback, s as attr_class, u as bind_props } from "./index-server.js";
import { t as Avatar } from "./Avatar.js";
//#region src/lib/components/VideoCard.svelte
function VideoCard($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let difficulty;
		let video = $$props["video"];
		let aspect = fallback($$props["aspect"], "video");
		const duration = (seconds = 0) => `${Math.floor((Number(seconds) || 0) / 60)}:${String((Number(seconds) || 0) % 60).padStart(2, "0")}`;
		const compact = (value = 0) => new Intl.NumberFormat("ru-RU", { notation: "compact" }).format(Number(value) || 0);
		const difficultyRu = {
			beginner: "Начальный",
			intermediate: "Средний",
			advanced: "Сложный"
		};
		$: difficulty = (video?.difficulty || "beginner").toLowerCase();
		$$renderer.push(`<a${attr("href", `/video/${video?.slug || ""}`)}${attr_class(`video-card ${aspect}`, "svelte-t34n65")}><div class="thumb-wrap svelte-t34n65">`);
		if (video?.thumbnail_url) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<img${attr("src", video.thumbnail_url)}${attr("alt", video.title)} loading="lazy" class="svelte-t34n65"/>`);
		} else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<div class="placeholder svelte-t34n65">LF</div>`);
		}
		$$renderer.push(`<!--]--> <div class="overlay svelte-t34n65"></div> <span${attr_class(`difficulty ${difficulty}`, "svelte-t34n65")}>${escape_html(difficultyRu[difficulty] || difficulty)}</span> <span class="duration svelte-t34n65">${escape_html(duration(video?.duration_seconds))}</span> <div class="info svelte-t34n65"><div class="author svelte-t34n65">`);
		Avatar($$renderer, {
			user: video?.creator,
			size: 24
		});
		$$renderer.push(`<!----><span>@${escape_html(video?.creator?.username || "")}</span></div> <h3 class="svelte-t34n65">${escape_html(video?.title || "")}</h3> <p class="svelte-t34n65">${escape_html(compact(video?.view_count))} просмотров · ${escape_html(compact(video?.like_count))} лайков</p></div></div></a>`);
		bind_props($$props, {
			video,
			aspect
		});
	});
}
//#endregion
export { VideoCard as t };
