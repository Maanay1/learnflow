import { sveltekit } from '@sveltejs/kit/vite';

export default {
  plugins: [sveltekit()],
  server: {
    port: 3000,
    proxy: {
      '/api': 'http://localhost:4000',
      '/socket': {
        target: 'ws://localhost:4000',
        ws: true
      }
    }
  }
};
