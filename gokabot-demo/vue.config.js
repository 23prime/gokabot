module.exports = {
    pages: {
        index: {
            entry: "src/main.ts",
            title: "gokabot-demo",
        },
    },
    devServer: {
        port: 3000,
        disableHostCheck: true,
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
            "Access-Control-Allow-Headers": "X-Requested-With, Content-Type, Authorization, Accept",
        },
    },
};
