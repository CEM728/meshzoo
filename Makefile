VERSION=$(shell python3 -c "import meshzoo; print(meshzoo.__version__)")

# ifneq "$(shell git rev-parse --abbrev-ref HEAD)" "master"
# $(error Not on master branch)
# endif

default:
	@echo "\"make publish\"?"

README.rst: README.md
	cat README.md | sed -e 's_<img src="\([^"]*\)" width="\([^"]*\)">_![](\1){width="\2"}_g' -e 's_<p[^>]*>__g' -e 's_</p>__g' > /tmp/README.md
	pandoc /tmp/README.md -o README.rst
	python3 setup.py check -r -s || exit 1

tag:
	# Make sure we're on the master branch
	@if [ "$(shell git rev-parse --abbrev-ref HEAD)" != "master" ]; then exit 1; fi
	@echo "Tagging v$(VERSION)..."
	git tag v$(VERSION)
	git push --tags

upload: setup.py README.rst
	# Make sure we're on the master branch
	@if [ "$(shell git rev-parse --abbrev-ref HEAD)" != "master" ]; then exit 1; fi
	rm -f dist/*
	python3 setup.py bdist_wheel --universal
	gpg --detach-sign -a dist/*
	twine upload dist/*

publish: tag upload

clean:
	rm -f README.rst
