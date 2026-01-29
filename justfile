dev:
    gleam run -m lustre/dev start

build:
    gleam run -m lustre/dev build --no-html

serve:
    npx serve .

run: build serve

clean:
    rm -rf dist
    rm -rf .lustre
    gleam clean
