import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Built into web/build, which fxmanifest serves as the panel's ui_page.
export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: 'build',
    emptyOutDir: true,
    assetsInlineLimit: 0,
    chunkSizeWarningLimit: 1000,
  },
});
