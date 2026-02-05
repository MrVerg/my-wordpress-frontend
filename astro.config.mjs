// @ts-check
import { defineConfig } from 'astro/config';

import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  image: {
    domains: ['localhost', 'dev-impresos-lebu.pantheonsite.io', 'images.unsplash.com'], // Permite optimizar imágenes de WP y externos
  },

  vite: {
    plugins: [tailwindcss()],
  },
});