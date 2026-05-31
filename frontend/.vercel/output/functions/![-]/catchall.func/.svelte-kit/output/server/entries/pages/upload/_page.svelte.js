import { $ as escape_html, Z as attr, _ as sanitize_props, b as store_get, p as ensure_array_like, s as attr_class, v as slot, x as unsubscribe_stores, y as spread_props } from "../../../chunks/index-server.js";
import { d as authStore } from "../../../chunks/api.js";
import { t as goto } from "../../../chunks/client.js";
import { t as Icon } from "../../../chunks/Icon.js";
import "../../../chunks/navigation.js";
//#region node_modules/lucide-svelte/dist/icons/cloud-upload.svelte
function Cloud_upload($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "cloud-upload" },
		sanitize_props($$props),
		{
			/**
			* @component @name CloudUpload
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMTIgMTN2OCIgLz4KICA8cGF0aCBkPSJNNCAxNC44OTlBNyA3IDAgMSAxIDE1LjcxIDhoMS43OWE0LjUgNC41IDAgMCAxIDIuNSA4LjI0MiIgLz4KICA8cGF0aCBkPSJtOCAxNyA0LTQgNCA0IiAvPgo8L3N2Zz4K) - https://lucide.dev/icons/cloud-upload
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [
				["path", { "d": "M12 13v8" }],
				["path", { "d": "M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242" }],
				["path", { "d": "m8 17 4-4 4 4" }]
			],
			children: ($$renderer) => {
				$$renderer.push(`<!--[-->`);
				slot($$renderer, $$props, "default", {}, null);
				$$renderer.push(`<!--]-->`);
			},
			$$slots: { default: true }
		}
	]));
}
//#endregion
//#region src/routes/upload/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
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
		let title = "";
		let description = "";
		let subject = "programming";
		let difficulty = "beginner";
		let uploading = false;
		let dragging = false;
		$: if (!store_get($$store_subs ??= {}, "$authStore", authStore).loading && !store_get($$store_subs ??= {}, "$authStore", authStore).authenticated) goto("/login");
		$$renderer.push(`<section class="shell max-w-3xl py-10"><h1 class="svelte-tziouu">Загрузить видео</h1> <div class="card svelte-tziouu"><h2 class="svelte-tziouu">1. Описание</h2> <input class="input svelte-tziouu"${attr("value", title)} placeholder="Название"/> <textarea class="input svelte-tziouu" placeholder="Описание">`);
		const $$body = escape_html(description);
		if ($$body) $$renderer.push(`${$$body}`);
		$$renderer.push(`</textarea> <div class="grid svelte-tziouu">`);
		$$renderer.select({
			class: "input",
			value: subject
		}, ($$renderer) => {
			$$renderer.push(`<!--[-->`);
			const each_array = ensure_array_like(subjects);
			for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
				let tag = each_array[$$index];
				$$renderer.option({ value: tag }, ($$renderer) => {
					$$renderer.push(`${escape_html(tag)}`);
				});
			}
			$$renderer.push(`<!--]-->`);
		}, "svelte-tziouu");
		$$renderer.push(` `);
		$$renderer.select({
			class: "input",
			value: difficulty
		}, ($$renderer) => {
			$$renderer.option({ value: "beginner" }, ($$renderer) => {
				$$renderer.push(`Начальный`);
			});
			$$renderer.option({ value: "intermediate" }, ($$renderer) => {
				$$renderer.push(`Средний`);
			});
			$$renderer.option({ value: "advanced" }, ($$renderer) => {
				$$renderer.push(`Сложный`);
			});
		}, "svelte-tziouu");
		$$renderer.push(`</div> <h2 class="svelte-tziouu">2. Видео</h2> <label${attr_class("drop svelte-tziouu", void 0, { "dragging": dragging })}><input type="file" accept="video/mp4,video/webm" class="svelte-tziouu"/> `);
		Cloud_upload($$renderer, { size: 34 });
		$$renderer.push(`<!----><strong>${escape_html("Перетащи видео сюда или нажми для выбора")}</strong> <span class="svelte-tziouu">${escape_html("MP4 или WebM, максимум 2 ГБ")}</span></label> <h2 class="svelte-tziouu">3. Публикация</h2> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <button class="publish svelte-tziouu"${attr("disabled", uploading, true)}>${escape_html("Загрузить видео")}</button></div></section>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
