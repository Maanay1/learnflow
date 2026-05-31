import * as universal from '../entries/pages/_page.js';

export const index = 2;
let component_cache;
export const component = async () => component_cache ??= (await import('../entries/pages/_page.svelte.js')).default;
export { universal };
export const universal_id = "src/routes/+page.js";
export const imports = ["_app/immutable/nodes/2.Bb6BWdyq.js","_app/immutable/chunks/B1V6r3Sh.js","_app/immutable/chunks/DNmNirid.js","_app/immutable/chunks/Psvp0VjL.js","_app/immutable/chunks/C-GWVNkq.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/Bk3GdLV7.js"];
export const stylesheets = [];
export const fonts = [];
