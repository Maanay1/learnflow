import { J as escape_html, K as attr, c as ensure_array_like, l as head, n as attr_class } from "../../../chunks/dev.js";
import "../../../chunks/api.js";
import "../../../chunks/navigation.js";
import { s as videos } from "../../../chunks/mockData.js";
//#region src/routes/login/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let email = "";
		let password = "";
		let remember = true;
		let loading = false;
		head("1x05zx6", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Войти | LearnFlow</title>`);
			});
		});
		$$renderer.push(`<section class="auth-page svelte-1x05zx6"><aside class="svelte-1x05zx6"><h1 class="svelte-1x05zx6">Учись у лучших</h1> <div class="mosaic svelte-1x05zx6"><!--[-->`);
		const each_array = ensure_array_like(videos.slice(0, 6));
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let video = each_array[$$index];
			$$renderer.push(`<img${attr("src", video.thumbnail_url)} alt="" class="svelte-1x05zx6"/>`);
		}
		$$renderer.push(`<!--]--></div></aside> <form class="svelte-1x05zx6"><a class="logo svelte-1x05zx6" href="/feed">LearnFlow</a> <label${attr_class("svelte-1x05zx6", void 0, { "filled": email })}><input${attr("value", email)} type="email" autocomplete="email" class="svelte-1x05zx6"/> <span class="svelte-1x05zx6">Email</span></label> <label${attr_class("svelte-1x05zx6", void 0, { "filled": password })}><input${attr("value", password)} type="password" autocomplete="current-password" class="svelte-1x05zx6"/> <span class="svelte-1x05zx6">Пароль</span></label> <label class="remember svelte-1x05zx6"><input type="checkbox"${attr("checked", remember, true)}/> Запомнить меня</label> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <button class="submit svelte-1x05zx6"${attr("disabled", loading, true)}>${escape_html("Войти")}</button> <div class="or svelte-1x05zx6"><span class="svelte-1x05zx6"></span>или<span class="svelte-1x05zx6"></span></div> <button class="google svelte-1x05zx6" type="button">Продолжить с Google</button> <p class="svelte-1x05zx6">Нет аккаунта? <a href="/register" class="svelte-1x05zx6">Зарегистрироваться</a></p></form></section>`);
	});
}
//#endregion
export { _page as default };
