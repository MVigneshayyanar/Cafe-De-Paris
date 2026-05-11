import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [sveltekit()],
	server: {
		proxy: {
			'/api': {
				target: 'http://127.0.0.1:8080',
				changeOrigin: true,
				rewrite: (path) => path.replace(/^\/api/, ''),
				configure: (proxy) => {
					proxy.on('proxyRes', (proxyRes, req, res) => {
						// Forward cookies
						const setCookie = proxyRes.headers['set-cookie'];
						if (setCookie) {
							res.setHeader('set-cookie', setCookie);
						}
					});
				}
			}
		}
	}
});
