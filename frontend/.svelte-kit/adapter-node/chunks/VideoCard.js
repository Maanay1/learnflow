import { J as escape_html, K as attr, a as bind_props, n as attr_class, r as attr_style, rt as fallback } from "./dev.js";
//#region src/lib/components/VideoCard.svelte
function VideoCard($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let creator, tag, difficulty, thumbnail;
		let video = $$props["video"];
		let aspect = fallback($$props["aspect"], "video");
		const duration = (seconds = 0) => `${Math.floor((Number(seconds) || 0) / 60)}:${String((Number(seconds) || 0) % 60).padStart(2, "0")}`;
		const compact = (value = 0) => {
			const n = Number(value) || 0;
			return n >= 1e3 ? `${(n / 1e3).toFixed(n >= 1e4 ? 0 : 1).replace(".", ",")}к` : `${n}`;
		};
		const difficultyRu = {
			beginner: "Начальный",
			intermediate: "Средний",
			advanced: "Сложный"
		};
		$: creator = video?.creator || {};
		$: tag = video?.tags?.[0] || {};
		$: difficulty = (video?.difficulty || "beginner").toLowerCase();
		$: thumbnail = video?.thumbnail_url || video?.wide_thumbnail_url || `https://picsum.photos/seed/${video?.id || "learnflow"}/900/1200`;
		$$renderer.push(`<a${attr("href", `/video/${video?.slug || ""}`)}${attr_class(`video-card ${aspect}`, "svelte-t34n65")}><div class="thumb-wrap svelte-t34n65"><img${attr("src", thumbnail)}${attr("alt", video?.title || "LearnFlow video")} loading="lazy" class="svelte-t34n65"/> <div class="overlay svelte-t34n65"></div> <span${attr_class(`badge-difficulty ${difficulty}`, "svelte-t34n65")}>${escape_html(difficultyRu[difficulty] || difficulty)}</span> <span class="badge-duration svelte-t34n65">${escape_html(duration(video?.duration_seconds))}</span> <div class="card-info svelte-t34n65"><div class="author-row svelte-t34n65"><img class="author-avatar svelte-t34n65"${attr("src", creator.avatar_url || "https://i.pravatar.cc/80?img=47")} alt=""/> <span class="author-name svelte-t34n65">@${escape_html(creator.username || "learnflow")}</span></div> <h3 class="video-title svelte-t34n65">${escape_html(video?.title || "Новый урок")}</h3> <div class="stats-row svelte-t34n65"><span>👁 ${escape_html(compact(video?.view_count))}</span> <span>❤️ ${escape_html(compact(video?.like_count))}</span> <span class="tag-pill svelte-t34n65"${attr_style(`background:${tag.color || "#6366f1"}`)}>${escape_html(tag.name || "LearnFlow")}</span></div></div></div></a>`);
		bind_props($$props, {
			video,
			aspect
		});
	});
}
//#endregion
export { VideoCard as t };
