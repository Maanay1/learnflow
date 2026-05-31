import { $ as escape_html, Z as attr, _ as sanitize_props, ot as fallback, u as bind_props, v as slot, y as spread_props } from "./index-server.js";
import "./api.js";
import { t as Icon } from "./Icon.js";
import "./navigation.js";
//#region node_modules/lucide-svelte/dist/icons/eye.svelte
function Eye($$renderer, $$props) {
	/**
	* @license lucide-svelte v0.468.0 - ISC
	*
	* This source code is licensed under the ISC license.
	* See the LICENSE file in the root directory of this source tree.
	*/
	Icon($$renderer, spread_props([
		{ name: "eye" },
		sanitize_props($$props),
		{
			/**
			* @component @name Eye
			* @description Lucide SVG icon component, renders SVG Element with children.
			*
			* @preview ![img](data:image/svg+xml;base64,PHN2ZyAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogIHdpZHRoPSIyNCIKICBoZWlnaHQ9IjI0IgogIHZpZXdCb3g9IjAgMCAyNCAyNCIKICBmaWxsPSJub25lIgogIHN0cm9rZT0iIzAwMCIgc3R5bGU9ImJhY2tncm91bmQtY29sb3I6ICNmZmY7IGJvcmRlci1yYWRpdXM6IDJweCIKICBzdHJva2Utd2lkdGg9IjIiCiAgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIgogIHN0cm9rZS1saW5lam9pbj0icm91bmQiCj4KICA8cGF0aCBkPSJNMi4wNjIgMTIuMzQ4YTEgMSAwIDAgMSAwLS42OTYgMTAuNzUgMTAuNzUgMCAwIDEgMTkuODc2IDAgMSAxIDAgMCAxIDAgLjY5NiAxMC43NSAxMC43NSAwIDAgMS0xOS44NzYgMCIgLz4KICA8Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIzIiAvPgo8L3N2Zz4K) - https://lucide.dev/icons/eye
			* @see https://lucide.dev/guide/packages/lucide-svelte - Documentation
			*
			* @param {Object} props - Lucide icons props and any valid SVG attribute
			* @returns {FunctionalComponent} Svelte component
			*
			*/
			iconNode: [["path", { "d": "M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0" }], ["circle", {
				"cx": "12",
				"cy": "12",
				"r": "3"
			}]],
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
//#region src/lib/components/AuthCard.svelte
function AuthCard($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let registering;
		let initialMode = fallback($$props["initialMode"], "login");
		let mode = initialMode;
		let username = "";
		let email = "";
		let password = "";
		let confirmPassword = "";
		let loading = false;
		$: registering = mode === "register";
		$$renderer.push(`<section class="auth-page svelte-a034u4"><form class="card svelte-a034u4"><a class="logo svelte-a034u4" href="/feed">LearnFlow</a> <p class="subtitle svelte-a034u4">Учись. Общайся. Развивайся.</p> <button class="google svelte-a034u4" type="button"><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path fill="#4285F4" d="M22.6 12.2c0-.7-.1-1.5-.2-2.2H12v4.3h6a5.1 5.1 0 0 1-2.2 3.3v2.8h3.6c2.1-2 3.2-4.8 3.2-8.2Z"></path><path fill="#34A853" d="M12 23c3 0 5.5-1 7.4-2.6l-3.6-2.8c-1 .7-2.3 1-3.8 1a6.5 6.5 0 0 1-6.1-4.5H2.2V17A11.2 11.2 0 0 0 12 23Z"></path><path fill="#FBBC05" d="M5.9 14.1a6.7 6.7 0 0 1 0-4.2V7H2.2a11.1 11.1 0 0 0 0 10l3.7-2.9Z"></path><path fill="#EA4335" d="M12 5.4c1.8 0 3.4.6 4.7 1.8l3.5-3.4A11 11 0 0 0 2.2 7l3.7 2.9A6.5 6.5 0 0 1 12 5.4Z"></path></svg> Войти через Google</button> <div class="divider svelte-a034u4"><span class="svelte-a034u4"></span><b>или</b><span class="svelte-a034u4"></span></div> `);
		if (registering) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<input${attr("value", username)} autocomplete="username" placeholder="Имя пользователя" required="" class="svelte-a034u4"/>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <input${attr("value", email)} type="email" autocomplete="email" placeholder="Email" required="" class="svelte-a034u4"/> <label class="svelte-a034u4"><input${attr("value", password)}${attr("type", "password")}${attr("autocomplete", registering ? "new-password" : "current-password")} placeholder="Пароль" required="" class="svelte-a034u4"/><button type="button" aria-label="Показать пароль" class="svelte-a034u4">`);
		$$renderer.push("<!--[-1-->");
		Eye($$renderer, { size: 18 });
		$$renderer.push(`<!--]--></button></label> `);
		if (registering) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<input${attr("value", confirmPassword)} type="password" autocomplete="new-password" placeholder="Повторите пароль" required="" class="svelte-a034u4"/>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <button class="submit svelte-a034u4"${attr("disabled", loading, true)}>${escape_html(registering ? "Зарегистрироваться" : "Войти")}</button> <p class="toggle svelte-a034u4">${escape_html(registering ? "Уже есть аккаунт?" : "Нет аккаунта?")} <button type="button" class="svelte-a034u4">${escape_html(registering ? "Войти" : "Зарегистрироваться")}</button></p></form></section>`);
		bind_props($$props, { initialMode });
	});
}
//#endregion
export { AuthCard as t };
