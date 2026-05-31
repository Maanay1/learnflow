import { m as head } from "../../../chunks/index-server.js";
import { t as AuthCard } from "../../../chunks/AuthCard.js";
//#region src/routes/login/+page.svelte
function _page($$renderer) {
	head("1x05zx6", $$renderer, ($$renderer) => {
		$$renderer.title(($$renderer) => {
			$$renderer.push(`<title>Войти | LearnFlow</title>`);
		});
	});
	AuthCard($$renderer, { initialMode: "login" });
}
//#endregion
export { _page as default };
