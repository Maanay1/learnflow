import { J as escape_html, K as attr, g as unsubscribe_stores, h as store_get } from "../../../chunks/dev.js";
import { l as authStore } from "../../../chunks/api.js";
import { t as goto } from "../../../chunks/client.js";
import "../../../chunks/navigation.js";
import { t as Modal } from "../../../chunks/Modal.js";
//#region src/routes/settings/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let display_name = "";
		let bio = "";
		let avatar_key = "";
		let current = "";
		let password = "";
		let confirm = "";
		let danger = false;
		let deletePassword = "";
		$: if (!store_get($$store_subs ??= {}, "$authStore", authStore).loading && !store_get($$store_subs ??= {}, "$authStore", authStore).authenticated) goto("/login");
		$: if (store_get($$store_subs ??= {}, "$authStore", authStore).user && !display_name) {
			display_name = store_get($$store_subs ??= {}, "$authStore", authStore).user.display_name || "";
			bio = store_get($$store_subs ??= {}, "$authStore", authStore).user.bio || "";
			avatar_key = store_get($$store_subs ??= {}, "$authStore", authStore).user.avatar_key || "";
		}
		$$renderer.push(`<section class="shell max-w-3xl space-y-8 py-8"><h1 class="text-3xl font-black">Settings</h1> <section class="card space-y-4 p-5"><h2 class="text-xl font-bold">Profile</h2><input class="input"${attr("value", display_name)} placeholder="Display name"/><input class="input"${attr("value", avatar_key)} placeholder="Avatar key"/><textarea class="input min-h-28" placeholder="Bio">`);
		const $$body = escape_html(bio);
		if ($$body) $$renderer.push(`${$$body}`);
		$$renderer.push(`</textarea><button class="btn">Save</button></section> <section class="card space-y-4 p-5"><h2 class="text-xl font-bold">Password</h2><input class="input"${attr("value", current)} type="password" placeholder="Current password"/><input class="input"${attr("value", password)} type="password" placeholder="New password"/><input class="input"${attr("value", confirm)} type="password" placeholder="Confirm"/><button class="btn-secondary"${attr("disabled", false, true)}>Change password</button></section> <section class="rounded-xl border border-[#ef4444]/30 bg-[#ef4444]/10 p-5"><h2 class="text-xl font-bold text-[#ef4444]">Danger zone</h2><div class="mt-4 flex gap-3"><button class="btn-secondary">Export data</button><button class="rounded-xl bg-[#ef4444] px-4 py-2 font-bold">Удалить аккаунт</button></div></section></section> `);
		Modal($$renderer, {
			open: danger,
			title: "Удалить аккаунт",
			onClose: () => danger = false,
			children: ($$renderer) => {
				$$renderer.push(`<div class="space-y-4"><input class="input"${attr("value", deletePassword)} type="password" placeholder="Password"/><button class="rounded-xl bg-[#ef4444] px-4 py-2 font-bold">Confirm delete</button></div>`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!---->`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}
//#endregion
export { _page as default };
