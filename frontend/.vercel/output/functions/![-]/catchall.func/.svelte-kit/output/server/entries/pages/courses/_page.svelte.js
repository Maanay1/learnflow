import { Z as attr, ot as fallback, p as ensure_array_like, s as attr_class, u as bind_props } from "../../../chunks/index-server.js";
import "../../../chunks/api.js";
import "../../../chunks/CourseCard.js";
//#region src/lib/components/LoadingSkeleton.svelte
function LoadingSkeleton($$renderer, $$props) {
	let className = fallback($$props["className"], "h-4 w-full");
	$$renderer.push(`<div${attr_class(`${className} skeleton rounded-lg`)}></div>`);
	bind_props($$props, { className });
}
//#endregion
//#region src/routes/courses/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let filters = {
			subject_tag_id: "",
			difficulty: "",
			price: ""
		};
		$$renderer.push(`<section class="shell space-y-6 py-8"><div class="flex flex-col gap-4 md:flex-row md:items-end md:justify-between"><div><p class="font-bold text-primary">LearnFlow Courses</p> <h1 class="text-3xl font-black">Курсы</h1></div> <div class="grid gap-2 sm:grid-cols-3"><input class="input"${attr("value", filters.subject_tag_id)} placeholder="subject tag id"/> `);
		$$renderer.select({
			class: "input",
			value: filters.difficulty
		}, ($$renderer) => {
			$$renderer.option({ value: "" }, ($$renderer) => {
				$$renderer.push(`Любая сложность`);
			});
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
			value: filters.price
		}, ($$renderer) => {
			$$renderer.option({ value: "" }, ($$renderer) => {
				$$renderer.push(`Любая цена`);
			});
			$$renderer.option({ value: "free" }, ($$renderer) => {
				$$renderer.push(`Бесплатно`);
			});
			$$renderer.option({ value: "paid" }, ($$renderer) => {
				$$renderer.push(`Платные`);
			});
		});
		$$renderer.push(`</div></div> `);
		{
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3"><!--[-->`);
			const each_array = ensure_array_like(Array(6));
			for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
				each_array[$$index];
				LoadingSkeleton($$renderer, { className: "h-72" });
			}
			$$renderer.push(`<!--]--></div>`);
		}
		$$renderer.push(`<!--]--></section>`);
	});
}
//#endregion
export { _page as default };
