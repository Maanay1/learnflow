import vercelAdapter from '@sveltejs/adapter-vercel';
import staticAdapter from '@sveltejs/adapter-static';

const adapter =
  process.env.SVELTE_ADAPTER === 'static'
    ? staticAdapter({ fallback: 'index.html' })
    : vercelAdapter({ runtime: 'nodejs24.x' });

export default {
  kit: {
    adapter
  }
};
