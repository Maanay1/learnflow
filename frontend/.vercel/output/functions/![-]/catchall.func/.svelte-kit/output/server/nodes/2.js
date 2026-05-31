import * as universal from '../entries/pages/_page.js';

export const index = 2;
let component_cache;
export const component = async () => component_cache ??= (await import('../entries/pages/_page.svelte.js')).default;
export { universal };
export const universal_id = "src/routes/+page.js";
export const imports = ["_app/immutable/nodes/2.Cbf1y5TF.js","_app/immutable/chunks/CVbzDXk1.js","_app/immutable/chunks/B_Oub3C-.js","_app/immutable/chunks/D0IxJBi2.js","_app/immutable/chunks/DIwafHJB.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/DtW1KYSt.js"];
export const stylesheets = [];
export const fonts = [];
