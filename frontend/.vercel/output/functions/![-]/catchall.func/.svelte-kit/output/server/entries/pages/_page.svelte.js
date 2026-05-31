import "../../chunks/index-server.js";
import "../../chunks/client.js";
import "../../chunks/navigation.js";
//#region src/routes/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		$$renderer.push(`<section class="grid min-h-screen place-items-center bg-black"><div class="skeleton h-48 w-80 rounded-lg"></div></section>`);
	});
}
//#endregion
export { _page as default };
