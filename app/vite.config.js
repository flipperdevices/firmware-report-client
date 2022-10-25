import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import ImportMetaEnvPlugin from "@import-meta-env/unplugin";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    svelte(),
    ImportMetaEnvPlugin.vite({
      example: ".env.example",
    }),
  ]
})
