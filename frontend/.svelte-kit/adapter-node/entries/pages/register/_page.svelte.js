import { J as escape_html, K as attr, c as ensure_array_like, l as head, n as attr_class } from "../../../chunks/dev.js";
import "../../../chunks/api.js";
import "../../../chunks/navigation.js";
import { s as videos } from "../../../chunks/mockData.js";
//#region src/routes/register/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let username = "";
		let email = "";
		let password = "";
		let loading = false;
		head("52fghe", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Регистрация | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="auth-page svelte-52fghe"><aside class="svelte-52fghe"><h1 class="svelte-52fghe">Учись у лучших</h1> <div class="mosaic svelte-52fghe"><!--[-->`);
		const each_array = ensure_array_like(videos.slice(6, 12));
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let video = each_array[$$index];
			$$renderer.push(`<img${attr("src", video.thumbnail_url)} alt="" class="svelte-52fghe"/>`);
		}
		$$renderer.push(`<!--]--></div></aside> <form class="svelte-52fghe"><a class="logo svelte-52fghe" href="/feed">LearnFlow</a> <label${attr_class("svelte-52fghe", void 0, { "filled": username })}><input${attr("value", username)} autocomplete="username" class="svelte-52fghe"/><span class="svelte-52fghe">Username</span></label> <label${attr_class("svelte-52fghe", void 0, { "filled": email })}><input${attr("value", email)} type="email" autocomplete="email" class="svelte-52fghe"/><span class="svelte-52fghe">Email</span></label> <label${attr_class("svelte-52fghe", void 0, { "filled": password })}><input${attr("value", password)} type="password" autocomplete="new-password" class="svelte-52fghe"/><span class="svelte-52fghe">Пароль</span></label> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <button class="submit svelte-52fghe"${attr("disabled", loading, true)}>${escape_html("Создать аккаунт")}</button> <div class="or svelte-52fghe"><span class="svelte-52fghe"></span>или<span class="svelte-52fghe"></span></div> <button class="google svelte-52fghe" type="button">Продолжить с Google</button> <p class="svelte-52fghe">Уже есть аккаунт? <a href="/login" class="svelte-52fghe">Войти</a></p></form></section>`);
	});
}
//#endregion
export { _page as default };
