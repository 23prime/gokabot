module.exports = {
    pages: {
        index: {
            entry: "src/main.ts",
            title: "gokabot-demo",
        },
    },
    devServer: {
        port: 3000,
        allowedHosts: "all",
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
            "Access-Control-Allow-Headers": "X-Requested-With, Content-Type, Authorization, Accept",
        },
    },
    chainWebpack: (config) => {
        config.resolve.alias.set("vue", "@vue/compat");
        config.module
            .rule("vue")
            .use("vue-loader")
            .tap((options) => {
                return {
                    ...options,
                    compilerOptions: {
                        compatConfig: {
                            MODE: 3,
                        },
                    },
                };
            });
    },
};
