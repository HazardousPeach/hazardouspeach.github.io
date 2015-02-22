

build:
	jekyll build

publish: build
	rsync -a _site/ uwplse.org:/var/www/alex
