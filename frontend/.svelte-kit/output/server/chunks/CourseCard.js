import { $ as escape_html, Z as attr, c as attr_style, u as bind_props } from "./index-server.js";
import { t as Avatar } from "./Avatar.js";
import { n as DifficultyBadge, t as TagPill } from "./TagPill.js";
//#region src/lib/components/CourseCard.svelte
function CourseCard($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let course = $$props["course"];
		const price = (course) => course?.is_paid ? `${Math.round((course.price_cents || 0) / 100)} ₽` : "Бесплатно";
		const duration = (seconds = 0) => `${Math.round((seconds || 0) / 60)} мин`;
		$$renderer.push(`<a${attr("href", `/courses/${course.slug}`)} class="group block overflow-hidden rounded-xl border bg-[var(--surface)] transition duration-200 hover:scale-[1.02]" style="border-color:var(--border)"><div class="relative aspect-video bg-[var(--surface-2)]">`);
		if (course.thumbnail_url) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<img${attr("src", course.thumbnail_url)}${attr("alt", course.title)} class="h-full w-full object-cover" loading="lazy"/>`);
		} else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<div class="grid h-full place-items-center bg-[var(--primary-subtle)] text-5xl font-black text-primary">LF</div>`);
		}
		$$renderer.push(`<!--]--> <span class="absolute bottom-2 right-2 rounded-lg bg-black/75 px-2 py-1 text-xs font-semibold text-white">${escape_html(price(course))}</span></div> <div class="space-y-3 p-4"><div class="flex items-center gap-2 text-sm text-[var(--text-2)]">`);
		Avatar($$renderer, {
			user: course.creator,
			size: 24
		});
		$$renderer.push(`<!----> <span class="truncate">${escape_html(course.creator?.display_name || course.creator?.username || "Creator")}</span></div> <h3 class="line-clamp-2 min-h-12 font-bold text-[var(--text)]">${escape_html(course.title)}</h3> <div class="flex flex-wrap items-center gap-2">`);
		if (course.subject_tag) {
			$$renderer.push("<!--[0-->");
			TagPill($$renderer, { tag: course.subject_tag });
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		DifficultyBadge($$renderer, { difficulty: course.difficulty });
		$$renderer.push(`<!----></div> <div class="flex justify-between text-xs text-[var(--text-3)]"><span>${escape_html(course.video_count || 0)} видео</span> <span>${escape_html(duration(course.duration_seconds))}</span></div> `);
		if (course.progress) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="h-2 rounded-full bg-[var(--surface-2)]"><div class="progress-fill h-full rounded-full bg-primary"${attr_style(`width:${course.progress.percent || 0}%`)}></div></div>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--></div></a>`);
		bind_props($$props, { course });
	});
}
//#endregion
export { CourseCard as t };
