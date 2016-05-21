# make tasks to create and publish packages
.PHONY: rpm deb packages deploy-packages

local-install:
	$(MAKE) install PREFIX=usr

NAME=plustache
VERSION = $(shell git describe --tags --always --dirty)
BUILDER = $(shell echo "`git config user.name` <`git config user.email`>")
PKG_RELEASE ?= 1
PROJECT_URL="https://github.com/mrtazz/$(NAME)"
FPM_FLAGS= --name $(NAME) --version $(VERSION) --iteration $(PKG_RELEASE) \
           --epoch 1 --license MIT --maintainer "$(BUILDER)" --url $(PROJECT_URL) \
           --vendor mrtazz --description "{{mustaches}} for C++" \
           --after-install utils/runldconfig.sh --after-remove utils/runldconfig.sh

rpm:
	  fpm -t rpm -s dir $(FPM_FLAGS) --depends boost-regex usr

deb:
	  fpm -t deb -s dir $(FPM_FLAGS) --depends libboost-regex usr

packages: local-install rpm deb

deploy-packages: packages
	package_cloud push mrtazz/$(NAME)/el/7 *.rpm
	package_cloud push mrtazz/$(NAME)/debian/wheezy *.deb
	package_cloud push mrtazz/$(NAME)/ubuntu/trusty *.deb
