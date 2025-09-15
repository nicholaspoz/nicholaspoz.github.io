mod split_flap

serve: 
  npx serve .

[parallel]
dev: serve split_flap::dev