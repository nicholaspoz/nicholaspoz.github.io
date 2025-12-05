# build:
#     gleam run -m lustre/dev build --outdir=../js

# dev:
#     pwd
#     watchexec --restart --verbose --wrap-process=session --stop-signal SIGTERM --exts gleam,mjs --ignore build/ --ignore ../js/ --watch src/ -- "just build"

dev:
    gleam run -m lustre/dev start

build:
    gleam run -m lustre/dev build