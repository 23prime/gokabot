# gokabot-demo

## Usage

### Switch localhost or deployed (development)

`gokabot-demo` support localhost and development environment.

In Default, it is setting AWS/development.  
If want to switch another URL, send message `dev` or `local` in chat.

## Development

### Serve for local development

```sh
$ yarn serve
```

And access to <http://localhost:3000>.

### Build

```sh
$ yarn build
```

### Deploy

Check generated files:

```sh
$ ls dist
css/
js/
favicon.ico
index.html
```

Run deploy shell:

```sh
$ ./deploy-to-s3.sh
```
