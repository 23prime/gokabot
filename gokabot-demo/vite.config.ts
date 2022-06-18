// See: https://vitejs.dev/config/
import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
    plugins: [vue(), tsconfigPaths()],
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
});
