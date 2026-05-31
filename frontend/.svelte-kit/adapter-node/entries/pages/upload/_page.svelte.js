import { J as escape_html, K as attr, c as ensure_array_like, g as unsubscribe_stores, h as store_get, n as attr_class } from "../../../chunks/dev.js";
import { l as authStore } from "../../../chunks/api.js";
import { t as goto } from "../../../chunks/client.js";
import "../../../chunks/navigation.js";
import "../../../chunks/VideoCard.js";
//#region src/routes/upload/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let step = 1;
		let title = "";
		let description = "";
		let difficulty = "beginner";
		let language = "ru";
		let tags = [];
		let chapters = [];
		const subjects = [
			"mathematics",
			"physics",
			"chemistry",
			"biology",
			"programming",
			"history",
			"languages",
			"economics",
			"design",
			"philosophy"
		];
		$: if (!store_get($$store_subs ??= {}, "$authStore", authStore).loading && (!store_get($$store_subs ??= {}, "$authStore", authStore).authenticated || !store_get($$store_subs ??= {}, "$authStore", authStore).user?.is_creator)) goto("/feed");
		$$renderer.push(`<section class="shell max-w-5xl py-8"><h1 class="mb-6 text-3xl font-black">Creator Upload</h1> <div class="mb-6 hidden grid-cols-4 gap-2 md:grid"><!--[-->`);
		const each_array = ensure_array_like([
			1,
			2,
			3,
			4
		]);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let n = each_array[$$index];
			$$renderer.push(`<button${attr_class(`rounded-xl p-3 ${step === n ? "bg-primary" : "bg-[#1a1a1a]"}`)}${attr("aria-label", `Go to upload step ${n}`)}>Step ${escape_html(n)}</button>`);
		}
		$$renderer.push(`<!--]--></div> <div class="mb-6 space-y-2 md:hidden"><!--[-->`);
		const each_array_1 = ensure_array_like([
			1,
			2,
			3,
			4
		]);
		for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
			let n = each_array_1[$$index_1];
			$$renderer.push(`<button${attr_class(`w-full rounded-xl p-3 text-left ${step === n ? "bg-primary" : "bg-[#1a1a1a]"}`)}${attr("aria-expanded", step === n)}>Step ${escape_html(n)}</button>`);
		}
		$$renderer.push(`<!--]--></div> <div class="card p-6">`);
		{
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="space-y-4"><input class="input"${attr("value", title)} placeholder="Title"/> <textarea class="input min-h-32" placeholder="Description">`);
			const $$body = escape_html(description);
			if ($$body) $$renderer.push(`${$$body}`);
			$$renderer.push(`</textarea> <div class="flex flex-wrap gap-2"><!--[-->`);
			const each_array_2 = ensure_array_like(subjects);
			for (let $$index_2 = 0, $$length = each_array_2.length; $$index_2 < $$length; $$index_2++) {
				let tag = each_array_2[$$index_2];
				$$renderer.push(`<label class="rounded-full bg-[#242424] px-3 py-1 text-sm"><input type="checkbox"${attr("checked", tags.includes(tag), true)}${attr("value", tag)}/> ${escape_html(tag)}</label>`);
			}
			$$renderer.push(`<!--]--></div> `);
			$$renderer.select({
				class: "input",
				value: difficulty
			}, ($$renderer) => {
				$$renderer.option({ value: "beginner" }, ($$renderer) => {
					$$renderer.push(`Beginner`);
				});
				$$renderer.option({ value: "intermediate" }, ($$renderer) => {
					$$renderer.push(`Intermediate`);
				});
				$$renderer.option({ value: "advanced" }, ($$renderer) => {
					$$renderer.push(`Advanced`);
				});
			});
			$$renderer.push(` `);
			$$renderer.select({
				class: "input",
				value: language
			}, ($$renderer) => {
				$$renderer.option({ value: "ru" }, ($$renderer) => {
					$$renderer.push(`RU`);
				});
				$$renderer.option({ value: "en" }, ($$renderer) => {
					$$renderer.push(`EN`);
				});
			});
			$$renderer.push(` <div class="space-y-2"><button class="btn-secondary">Add chapter</button><!--[-->`);
			const each_array_3 = ensure_array_like(chapters);
			for (let i = 0, $$length = each_array_3.length; i < $$length; i++) {
				let chapter = each_array_3[i];
				$$renderer.push(`<div class="grid gap-2 md:grid-cols-[1fr_120px_auto]"><input class="input"${attr("value", chapter.title)} placeholder="Chapter title"/><input class="input"${attr("value", chapter.timestamp)} placeholder="MM:SS"/><button class="btn-secondary">Remove</button></div>`);
			}
			$$renderer.push(`<!--]--></div></div>`);
		}
		$$renderer.push(`<!--]--></div></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
