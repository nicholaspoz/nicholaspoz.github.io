dev:
    gleam run -m lustre/dev start

build:
    gleam run -m lustre/dev build --outdir=js

serve:
    npx serve .
