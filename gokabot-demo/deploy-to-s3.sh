aws s3 cp dist/index.html s3://gokabot-demo
aws s3 cp dist/favicon.ico s3://gokabot-demo
aws s3 cp dist/css s3://gokabot-demo/css --recursive
aws s3 cp dist/js s3://gokabot-demo/js --recursive
