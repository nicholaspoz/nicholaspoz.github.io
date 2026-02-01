dev:
    gleam run -m lustre/dev start

build:
    gleam run -m lustre/dev build --no-html

serve:
    npx serve .

run: build
    npx concurrently -k "npx serve ." "npx chokidar-cli 'src/**/*' 'assets/**/*' '*.html' -c 'just build'"

clean:
    rm -rf dist
    rm -rf .lustre
    gleam clean
