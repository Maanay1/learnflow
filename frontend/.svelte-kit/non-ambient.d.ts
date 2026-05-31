
// this file is generated — do not edit it


declare module "svelte/elements" {
	export interface HTMLAttributes<T> {
		'data-sveltekit-keepfocus'?: true | '' | 'off' | undefined | null;
		'data-sveltekit-noscroll'?: true | '' | 'off' | undefined | null;
		'data-sveltekit-preload-code'?:
			| true
			| ''
			| 'eager'
			| 'viewport'
			| 'hover'
			| 'tap'
			| 'off'
			| undefined
			| null;
		'data-sveltekit-preload-data'?: true | '' | 'hover' | 'tap' | 'off' | undefined | null;
		'data-sveltekit-reload'?: true | '' | 'off' | undefined | null;
		'data-sveltekit-replacestate'?: true | '' | 'off' | undefined | null;
	}
}

export {};


declare module "$app/types" {
	type MatcherParam<M> = M extends (param : string) => param is (infer U extends string) ? U : string;

	export interface AppTypes {
		RouteId(): "/" | "/courses" | "/courses/[slug]" | "/dashboard" | "/feed" | "/login" | "/messages" | "/notifications" | "/profile" | "/profile/[username]" | "/register" | "/search" | "/settings" | "/upload" | "/video" | "/video/[slug]";
		RouteParams(): {
			"/courses/[slug]": { slug: string };
			"/profile/[username]": { username: string };
			"/video/[slug]": { slug: string }
		};
		LayoutParams(): {
			"/": { slug?: string | undefined; username?: string | undefined };
			"/courses": { slug?: string | undefined };
			"/courses/[slug]": { slug: string };
			"/dashboard": Record<string, never>;
			"/feed": Record<string, never>;
			"/login": Record<string, never>;
			"/messages": Record<string, never>;
			"/notifications": Record<string, never>;
			"/profile": { username?: string | undefined };
			"/profile/[username]": { username: string };
			"/register": Record<string, never>;
			"/search": Record<string, never>;
			"/settings": Record<string, never>;
			"/upload": Record<string, never>;
			"/video": { slug?: string | undefined };
			"/video/[slug]": { slug: string }
		};
		Pathname(): "/" | "/courses" | `/courses/${string}` & {} | "/dashboard" | "/feed" | "/login" | "/messages" | "/notifications" | `/profile/${string}` & {} | "/register" | "/search" | "/settings" | "/upload" | `/video/${string}` & {};
		ResolvedPathname(): `${"" | `/${string}`}${ReturnType<AppTypes['Pathname']>}`;
		Asset(): string & {};
	}
}