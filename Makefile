

build:
	jekyll build

publish: build
	rsync -a _site/ uwplse.org:/var/www/alex
	mv _config.yml _config_uw.yml
	mv _config_ucsd.yml _config.yml
	jekyll build
	rsync -a _site/ alexss@login.eng.ucsd.edu:public_html
	mv _config.yml _config_ucsd.yml
	mv _config_uw.yml _config.yml
