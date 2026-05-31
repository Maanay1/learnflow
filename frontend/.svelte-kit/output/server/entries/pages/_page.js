import { redirect } from "@sveltejs/kit";
//#region src/routes/+page.js
function load() {
	throw redirect(307, "/feed");
}
//#endregion
export { load };
