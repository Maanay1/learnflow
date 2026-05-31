import { m as head } from "../../../chunks/index-server.js";
import { t as AuthCard } from "../../../chunks/AuthCard.js";
//#region src/routes/register/+page.svelte
function _page($$renderer) {
	head("52fghe", $$renderer, ($$renderer) => {
		$$renderer.title(($$renderer) => {
			$$renderer.push(`<title>Регистрация | LearnFlow</title>`);
		});
	});
	AuthCard($$renderer, { initialMode: "register" });
}
//#endregion
export { _page as default };
