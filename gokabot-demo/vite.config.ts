// See: https://vitejs.dev/config/
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import path, { resolve } from "path";

// TODO: use vite-tsconfig-paths

export default defineConfig({
    plugins: [vue()],
    server: {
        host: "0.0.0.0",
        port: 3000,
        strictPort: true,
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
            "Access-Control-Allow-Headers": "X-Requested-With, Content-Type, Authorization, Accept",
        },
    },
    resolve: {
        alias: {
            "@": path.resolve(__dirname, "./src"),
        },
    },
});
